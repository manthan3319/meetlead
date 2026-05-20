const asyncHandler = require('../utils/asyncHandler');
const Service = require('../models/Service');

exports.list = asyncHandler(async (req, res) => {
  const items = await Service.find({ organizationId: req.user.organizationId, isActive: true }).sort('-createdAt');
  res.json({ success: true, data: items });
});

exports.create = asyncHandler(async (req, res) => {
  const item = await Service.create({ ...req.body, organizationId: req.user.organizationId });
  res.status(201).json({ success: true, data: item });
});

exports.update = asyncHandler(async (req, res) => {
  const item = await Service.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  res.json({ success: true, data: item });
});

exports.remove = asyncHandler(async (req, res) => {
  await Service.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { isActive: false }
  );
  res.json({ success: true, message: 'Service deleted' });
});
