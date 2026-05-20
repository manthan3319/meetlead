const asyncHandler = require('../utils/asyncHandler');
const Plan = require('../models/Plan');

exports.publicList = asyncHandler(async (req, res) => {
  const items = await Plan.find({ isActive: true, slug: { $ne: 'trial' } }).sort('sortOrder price');
  res.json({ success: true, data: items });
});

exports.list = asyncHandler(async (req, res) => {
  const items = await Plan.find().sort('sortOrder price');
  res.json({ success: true, data: items });
});

exports.get = asyncHandler(async (req, res) => {
  const item = await Plan.findById(req.params.id);
  if (!item) return res.status(404).json({ success: false, message: 'Plan not found' });
  res.json({ success: true, data: item });
});

exports.create = asyncHandler(async (req, res) => {
  const item = await Plan.create(req.body);
  res.status(201).json({ success: true, data: item });
});

exports.update = asyncHandler(async (req, res) => {
  const item = await Plan.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json({ success: true, data: item });
});

exports.remove = asyncHandler(async (req, res) => {
  await Plan.findByIdAndUpdate(req.params.id, { isActive: false });
  res.json({ success: true });
});
