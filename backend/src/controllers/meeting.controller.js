const asyncHandler = require('../utils/asyncHandler');
const Meeting = require('../models/Meeting');
const Reminder = require('../models/Reminder');
const Activity = require('../models/Activity');

const buildReminders = (meeting, userId, orgId) => {
  const sched = new Date(meeting.scheduledAt);
  const cfg = [
    { minutesBefore: 24 * 60, style: 'notification' },
    { minutesBefore: 60, style: 'notification' },
    { minutesBefore: 15, style: 'notification' },
    { minutesBefore: 0, style: 'alarm' },
  ];
  return cfg.map((c) => ({
    organizationId: orgId,
    userId,
    refType: 'meeting',
    refId: meeting._id,
    title: meeting.title,
    body: meeting.description || `Meeting with ${meeting.leadId ? 'lead' : 'contact'}`,
    remindAt: new Date(sched.getTime() - c.minutesBefore * 60000),
    style: c.style,
  }));
};

exports.list = asyncHandler(async (req, res) => {
  const { status, from, to, page = 1, limit = 20 } = req.query;
  const filter = { organizationId: req.user.organizationId, isActive: true };
  if (status) filter.status = status;
  if (from || to) filter.scheduledAt = {};
  if (from) filter.scheduledAt.$gte = new Date(from);
  if (to) filter.scheduledAt.$lte = new Date(to);

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    Meeting.find(filter)
      .sort({ scheduledAt: 1 })
      .skip(skip)
      .limit(+limit)
      .populate('leadId', 'name phone email')
      .populate('assignedTo', 'name'),
    Meeting.countDocuments(filter),
  ]);
  res.json({ success: true, data: items, total, page: +page, pages: Math.ceil(total / limit) });
});

exports.upcoming = asyncHandler(async (req, res) => {
  const items = await Meeting.find({
    organizationId: req.user.organizationId,
    isActive: true,
    status: 'scheduled',
    scheduledAt: { $gte: new Date() },
  })
    .sort({ scheduledAt: 1 })
    .limit(20)
    .populate('leadId', 'name phone');
  res.json({ success: true, data: items });
});

exports.get = asyncHandler(async (req, res) => {
  const meeting = await Meeting.findOne({ _id: req.params.id, organizationId: req.user.organizationId })
    .populate('leadId')
    .populate('assignedTo', 'name email');
  if (!meeting) return res.status(404).json({ success: false, message: 'Meeting not found' });
  res.json({ success: true, data: meeting });
});

exports.create = asyncHandler(async (req, res) => {
  const meeting = await Meeting.create({
    ...req.body,
    organizationId: req.user.organizationId,
    createdBy: req.user._id,
    assignedTo: req.body.assignedTo || req.user._id,
  });
  const reminders = buildReminders(meeting, req.user._id, req.user.organizationId);
  await Reminder.insertMany(reminders);
  await Activity.create({
    organizationId: req.user.organizationId,
    userId: req.user._id,
    refType: 'meeting',
    refId: meeting._id,
    action: 'created',
    description: `Scheduled meeting: ${meeting.title}`,
  });
  res.status(201).json({ success: true, data: meeting });
});

exports.update = asyncHandler(async (req, res) => {
  const meeting = await Meeting.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  if (!meeting) return res.status(404).json({ success: false, message: 'Meeting not found' });

  if (req.body.scheduledAt) {
    await Reminder.deleteMany({ refType: 'meeting', refId: meeting._id, sent: false });
    const reminders = buildReminders(meeting, req.user._id, req.user.organizationId);
    await Reminder.insertMany(reminders);
  }
  res.json({ success: true, data: meeting });
});

exports.remove = asyncHandler(async (req, res) => {
  await Meeting.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { isActive: false }
  );
  await Reminder.deleteMany({ refType: 'meeting', refId: req.params.id, sent: false });
  res.json({ success: true, message: 'Meeting cancelled' });
});

exports.addNote = asyncHandler(async (req, res) => {
  const meeting = await Meeting.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { $set: { notes: req.body.notes, outcome: req.body.outcome, status: req.body.status || 'completed' } },
    { new: true }
  );
  res.json({ success: true, data: meeting });
});
