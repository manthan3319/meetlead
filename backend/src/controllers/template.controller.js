const asyncHandler = require('../utils/asyncHandler');
const Template = require('../models/Template');

exports.list = asyncHandler(async (req, res) => {
  const items = await Template.find({
    $or: [{ organizationId: req.user.organizationId }, { isGlobal: true }],
    isActive: true,
  });
  res.json({ success: true, data: items });
});

exports.create = asyncHandler(async (req, res) => {
  const item = await Template.create({ ...req.body, organizationId: req.user.organizationId });
  res.status(201).json({ success: true, data: item });
});

exports.update = asyncHandler(async (req, res) => {
  const item = await Template.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  res.json({ success: true, data: item });
});

exports.remove = asyncHandler(async (req, res) => {
  await Template.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { isActive: false }
  );
  res.json({ success: true });
});
