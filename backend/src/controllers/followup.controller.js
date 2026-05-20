const asyncHandler = require('../utils/asyncHandler');
const Followup = require('../models/Followup');
const Reminder = require('../models/Reminder');

exports.list = asyncHandler(async (req, res) => {
  const { status, leadId, from, to } = req.query;
  const filter = { organizationId: req.user.organizationId };
  if (status) filter.status = status;
  if (leadId) filter.leadId = leadId;
  if (from || to) filter.scheduledAt = {};
  if (from) filter.scheduledAt.$gte = new Date(from);
  if (to) filter.scheduledAt.$lte = new Date(to);

  const items = await Followup.find(filter).sort({ scheduledAt: 1 }).populate('leadId', 'name phone');
  res.json({ success: true, data: items });
});

exports.today = asyncHandler(async (req, res) => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  const end = new Date();
  end.setHours(23, 59, 59, 999);
  const items = await Followup.find({
    organizationId: req.user.organizationId,
    status: 'pending',
    scheduledAt: { $gte: start, $lte: end },
  }).populate('leadId', 'name phone');
  res.json({ success: true, data: items });
});

exports.create = asyncHandler(async (req, res) => {
  const item = await Followup.create({
    ...req.body,
    organizationId: req.user.organizationId,
    createdBy: req.user._id,
    assignedTo: req.body.assignedTo || req.user._id,
  });
  await Reminder.create({
    organizationId: req.user.organizationId,
    userId: item.assignedTo,
    refType: 'followup',
    refId: item._id,
    title: 'Follow-up reminder',
    body: item.note,
    remindAt: item.scheduledAt,
    style: 'notification',
  });
  res.status(201).json({ success: true, data: item });
});

exports.update = asyncHandler(async (req, res) => {
  const item = await Followup.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  res.json({ success: true, data: item });
});

exports.complete = asyncHandler(async (req, res) => {
  const item = await Followup.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { status: 'done', completedAt: new Date(), outcome: req.body.outcome },
    { new: true }
  );
  res.json({ success: true, data: item });
});

exports.remove = asyncHandler(async (req, res) => {
  await Followup.findOneAndDelete({ _id: req.params.id, organizationId: req.user.organizationId });
  res.json({ success: true, message: 'Follow-up deleted' });
});
