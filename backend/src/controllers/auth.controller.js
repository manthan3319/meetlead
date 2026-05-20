const asyncHandler = require('../utils/asyncHandler');
const User = require('../models/User');
const Organization = require('../models/Organization');
const Plan = require('../models/Plan');
const Subscription = require('../models/Subscription');
const { generateToken } = require('../utils/token');

exports.register = asyncHandler(async (req, res) => {
  const { name, email, phone, password, orgName } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ success: false, message: 'Name, email, password required' });
  }
  const exists = await User.findOne({ email });
  if (exists) return res.status(400).json({ success: false, message: 'Email already registered' });

  const user = await User.create({ name, email, phone, password, role: 'owner' });
  const org = await Organization.create({ name: orgName || `${name}'s Workspace`, ownerId: user._id });
  user.organizationId = org._id;
  await user.save();

  let subscription = null;
  const trialPlan = await Plan.findOne({ slug: 'trial' });
  if (trialPlan) {
    const start = new Date();
    const end = new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
    subscription = await Subscription.create({
      userId: user._id,
      organizationId: org._id,
      planId: trialPlan._id,
      status: 'trial',
      isTrial: true,
      startDate: start,
      endDate: end,
    });
    subscription = await Subscription.findById(subscription._id).populate('planId');
  }

  res.status(201).json({
    success: true,
    token: generateToken(user._id, user.role),
    user: { id: user._id, name: user.name, email: user.email, role: user.role, organizationId: org._id },
    subscription,
  });
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.matchPassword(password))) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }
  if (!user.isActive) return res.status(403).json({ success: false, message: 'Account disabled' });
  user.lastLoginAt = new Date();
  await user.save();

  const Subscription = require('../models/Subscription');
  const subscription = await Subscription.findOne({
    userId: user._id,
    status: { $in: ['active', 'trial'] },
    endDate: { $gt: new Date() },
  }).populate('planId');

  res.json({
    success: true,
    token: generateToken(user._id, user.role),
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      organizationId: user.organizationId,
      avatar: user.avatar,
    },
    subscription,
  });
});

exports.me = asyncHandler(async (req, res) => {
  res.json({ success: true, user: req.user });
});

exports.updateProfile = asyncHandler(async (req, res) => {
  const allowed = ['name', 'phone', 'avatar', 'preferences', 'fcmToken'];
  const updates = {};
  allowed.forEach((k) => req.body[k] !== undefined && (updates[k] = req.body[k]));
  const user = await User.findByIdAndUpdate(req.user._id, updates, { new: true });
  res.json({ success: true, user });
});

exports.changePassword = asyncHandler(async (req, res) => {
  const { current, next } = req.body;
  const user = await User.findById(req.user._id).select('+password');
  if (!(await user.matchPassword(current))) {
    return res.status(400).json({ success: false, message: 'Current password incorrect' });
  }
  user.password = next;
  await user.save();
  res.json({ success: true, message: 'Password changed' });
});
