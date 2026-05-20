const asyncHandler = require('../utils/asyncHandler');
const Subscription = require('../models/Subscription');

exports.current = asyncHandler(async (req, res) => {
  const sub = await Subscription.findOne({
    userId: req.user._id,
    status: { $in: ['active', 'trial'] },
    endDate: { $gt: new Date() },
  }).populate('planId');
  res.json({ success: true, data: sub });
});

exports.history = asyncHandler(async (req, res) => {
  const items = await Subscription.find({ userId: req.user._id }).populate('planId').sort('-createdAt');
  res.json({ success: true, data: items });
});

exports.adminList = asyncHandler(async (req, res) => {
  const { status, page = 1, limit = 30 } = req.query;
  const filter = {};
  if (status) filter.status = status;
  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    Subscription.find(filter)
      .populate('userId', 'name email')
      .populate('planId', 'name price durationMonths')
      .sort('-createdAt')
      .skip(skip)
      .limit(+limit),
    Subscription.countDocuments(filter),
  ]);
  res.json({ success: true, data: items, total, page: +page, pages: Math.ceil(total / limit) });
});

exports.adminUpdate = asyncHandler(async (req, res) => {
  const item = await Subscription.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json({ success: true, data: item });
});
