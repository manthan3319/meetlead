const crypto = require('crypto');
const asyncHandler = require('../utils/asyncHandler');
const Plan = require('../models/Plan');
const Payment = require('../models/Payment');
const Subscription = require('../models/Subscription');
const Setting = require('../models/Setting');
const { getRazorpay, getPublicKey } = require('../services/razorpay.service');

exports.config = asyncHandler(async (req, res) => {
  const keyId = await getPublicKey();
  res.json({ success: true, keyId, configured: !!keyId });
});

exports.createOrder = asyncHandler(async (req, res) => {
  const { planId } = req.body;
  const plan = await Plan.findById(planId);
  if (!plan || !plan.isActive) {
    return res.status(404).json({ success: false, message: 'Plan not available' });
  }
  const rzp = await getRazorpay();
  const order = await rzp.orders.create({
    amount: plan.price * 100,
    currency: plan.currency || 'INR',
    receipt: `rcpt_${Date.now()}`,
    notes: { userId: req.user._id.toString(), planId: plan._id.toString() },
  });
  const payment = await Payment.create({
    userId: req.user._id,
    planId: plan._id,
    razorpayOrderId: order.id,
    amount: plan.price,
    currency: plan.currency || 'INR',
    status: 'created',
  });
  res.json({
    success: true,
    order: { id: order.id, amount: order.amount, currency: order.currency },
    keyId: await getPublicKey(),
    paymentId: payment._id,
    plan: { id: plan._id, name: plan.name, price: plan.price },
  });
});

exports.verify = asyncHandler(async (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
  const keySecret = await Setting.findOne({ key: 'razorpay_key_secret' });
  const expected = crypto
    .createHmac('sha256', keySecret.value)
    .update(`${razorpay_order_id}|${razorpay_payment_id}`)
    .digest('hex');

  if (expected !== razorpay_signature) {
    await Payment.findOneAndUpdate({ razorpayOrderId: razorpay_order_id }, { status: 'failed' });
    return res.status(400).json({ success: false, message: 'Signature mismatch' });
  }

  const payment = await Payment.findOne({ razorpayOrderId: razorpay_order_id });
  if (!payment) return res.status(404).json({ success: false, message: 'Payment record missing' });

  payment.razorpayPaymentId = razorpay_payment_id;
  payment.razorpaySignature = razorpay_signature;
  payment.status = 'paid';
  await payment.save();

  const plan = await Plan.findById(payment.planId);
  const start = new Date();
  const end = new Date(start);
  end.setMonth(end.getMonth() + plan.durationMonths);

  await Subscription.updateMany(
    { userId: payment.userId, status: { $in: ['active', 'trial', 'pending'] } },
    { status: 'expired' }
  );

  const sub = await Subscription.create({
    userId: payment.userId,
    organizationId: req.user.organizationId,
    planId: plan._id,
    status: 'active',
    startDate: start,
    endDate: end,
    paymentId: payment._id,
    amountPaid: payment.amount,
  });

  payment.subscriptionId = sub._id;
  await payment.save();

  res.json({ success: true, subscription: sub, message: 'Payment verified, subscription activated' });
});

exports.history = asyncHandler(async (req, res) => {
  const items = await Payment.find({ userId: req.user._id }).populate('planId').sort('-createdAt');
  res.json({ success: true, data: items });
});

exports.adminList = asyncHandler(async (req, res) => {
  const { status, page = 1, limit = 30 } = req.query;
  const filter = {};
  if (status) filter.status = status;
  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    Payment.find(filter)
      .populate('userId', 'name email')
      .populate('planId', 'name price')
      .sort('-createdAt')
      .skip(skip)
      .limit(+limit),
    Payment.countDocuments(filter),
  ]);
  res.json({ success: true, data: items, total, page: +page, pages: Math.ceil(total / limit) });
});
