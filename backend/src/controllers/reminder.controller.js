const asyncHandler = require('../utils/asyncHandler');
const Reminder = require('../models/Reminder');

exports.pending = asyncHandler(async (req, res) => {
  const items = await Reminder.find({
    userId: req.user._id,
    sent: false,
    remindAt: { $lte: new Date(Date.now() + 60 * 60 * 1000) },
  }).sort({ remindAt: 1 });
  res.json({ success: true, data: items });
});

exports.all = asyncHandler(async (req, res) => {
  const items = await Reminder.find({ userId: req.user._id }).sort({ remindAt: -1 }).limit(100);
  res.json({ success: true, data: items });
});

exports.markSeen = asyncHandler(async (req, res) => {
  await Reminder.findOneAndUpdate(
    { _id: req.params.id, userId: req.user._id },
    { seen: true }
  );
  res.json({ success: true });
});

exports.create = asyncHandler(async (req, res) => {
  const item = await Reminder.create({
    ...req.body,
    userId: req.user._id,
    organizationId: req.user.organizationId,
    refType: req.body.refType || 'custom',
  });
  res.status(201).json({ success: true, data: item });
});
