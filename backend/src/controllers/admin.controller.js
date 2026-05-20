const asyncHandler = require('../utils/asyncHandler');
const User = require('../models/User');
const Organization = require('../models/Organization');
const Subscription = require('../models/Subscription');
const Payment = require('../models/Payment');
const Lead = require('../models/Lead');
const Meeting = require('../models/Meeting');

exports.stats = asyncHandler(async (req, res) => {
  const [users, orgs, activeSubs, totalRevenue, totalLeads, totalMeetings] = await Promise.all([
    User.countDocuments({ role: { $nin: ['superadmin', 'admin'] } }),
    Organization.countDocuments(),
    Subscription.countDocuments({ status: 'active', endDate: { $gt: new Date() } }),
    Payment.aggregate([{ $match: { status: 'paid' } }, { $group: { _id: null, total: { $sum: '$amount' } } }]),
    Lead.countDocuments({ isActive: true }),
    Meeting.countDocuments({ isActive: true }),
  ]);

  res.json({
    success: true,
    data: {
      users,
      organizations: orgs,
      activeSubscriptions: activeSubs,
      revenue: totalRevenue[0]?.total || 0,
      leads: totalLeads,
      meetings: totalMeetings,
    },
  });
});

exports.listUsers = asyncHandler(async (req, res) => {
  const { q, role, page = 1, limit = 30 } = req.query;
  const filter = {};
  if (role) filter.role = role;
  if (q) filter.$or = [{ name: new RegExp(q, 'i') }, { email: new RegExp(q, 'i') }];

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    User.find(filter).sort('-createdAt').skip(skip).limit(+limit).populate('organizationId', 'name'),
    User.countDocuments(filter),
  ]);
  res.json({ success: true, data: items, total, page: +page, pages: Math.ceil(total / limit) });
});

exports.userDetail = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id).populate('organizationId');
  const sub = await Subscription.findOne({
    userId: user._id,
    status: { $in: ['active', 'trial'] },
  }).populate('planId');
  const payments = await Payment.find({ userId: user._id }).sort('-createdAt').limit(20).populate('planId');
  res.json({ success: true, data: { user, subscription: sub, payments } });
});

exports.toggleUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  user.isActive = !user.isActive;
  await user.save();
  res.json({ success: true, data: user });
});

exports.updateUserRole = asyncHandler(async (req, res) => {
  const user = await User.findByIdAndUpdate(req.params.id, { role: req.body.role }, { new: true });
  res.json({ success: true, data: user });
});

exports.revenueChart = asyncHandler(async (req, res) => {
  const months = await Payment.aggregate([
    { $match: { status: 'paid' } },
    {
      $group: {
        _id: { y: { $year: '$createdAt' }, m: { $month: '$createdAt' } },
        total: { $sum: '$amount' },
        count: { $sum: 1 },
      },
    },
    { $sort: { '_id.y': 1, '_id.m': 1 } },
    { $limit: 12 },
  ]);
  res.json({ success: true, data: months });
});
