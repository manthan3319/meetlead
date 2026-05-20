const asyncHandler = require('../utils/asyncHandler');
const User = require('../models/User');

exports.teamList = asyncHandler(async (req, res) => {
  const users = await User.find({
    organizationId: req.user.organizationId,
    isActive: true,
  }).select('-password');
  res.json({ success: true, data: users });
});

exports.invite = asyncHandler(async (req, res) => {
  const { name, email, phone, role = 'sales', password } = req.body;
  const exists = await User.findOne({ email });
  if (exists) return res.status(400).json({ success: false, message: 'Email already exists' });
  const user = await User.create({
    name,
    email,
    phone,
    password: password || Math.random().toString(36).slice(2, 10),
    role,
    organizationId: req.user.organizationId,
  });
  res.status(201).json({ success: true, data: user });
});

exports.update = asyncHandler(async (req, res) => {
  const user = await User.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  res.json({ success: true, data: user });
});

exports.toggle = asyncHandler(async (req, res) => {
  const user = await User.findOne({ _id: req.params.id, organizationId: req.user.organizationId });
  user.isActive = !user.isActive;
  await user.save();
  res.json({ success: true, data: user });
});
