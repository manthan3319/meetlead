const asyncHandler = require('../utils/asyncHandler');
const Lead = require('../models/Lead');
const Activity = require('../models/Activity');

exports.list = asyncHandler(async (req, res) => {
  const { status, source, priority, q, page = 1, limit = 20 } = req.query;
  const filter = { organizationId: req.user.organizationId, isActive: true };
  if (status) filter.status = status;
  if (source) filter.source = source;
  if (priority) filter.priority = priority;
  if (q) filter.$or = [
    { name: new RegExp(q, 'i') },
    { phone: new RegExp(q, 'i') },
    { email: new RegExp(q, 'i') },
    { company: new RegExp(q, 'i') },
  ];

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    Lead.find(filter).sort({ createdAt: -1 }).skip(skip).limit(+limit).populate('assignedTo', 'name email'),
    Lead.countDocuments(filter),
  ]);
  res.json({ success: true, data: items, total, page: +page, pages: Math.ceil(total / limit) });
});

exports.get = asyncHandler(async (req, res) => {
  const lead = await Lead.findOne({ _id: req.params.id, organizationId: req.user.organizationId })
    .populate('assignedTo', 'name email')
    .populate('services');
  if (!lead) return res.status(404).json({ success: false, message: 'Lead not found' });
  res.json({ success: true, data: lead });
});

exports.create = asyncHandler(async (req, res) => {
  const lead = await Lead.create({
    ...req.body,
    organizationId: req.user.organizationId,
    createdBy: req.user._id,
    assignedTo: req.body.assignedTo || req.user._id,
  });
  await Activity.create({
    organizationId: req.user.organizationId,
    userId: req.user._id,
    refType: 'lead',
    refId: lead._id,
    action: 'created',
    description: `Created lead: ${lead.name}`,
  });
  res.status(201).json({ success: true, data: lead });
});

exports.update = asyncHandler(async (req, res) => {
  const lead = await Lead.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    req.body,
    { new: true }
  );
  if (!lead) return res.status(404).json({ success: false, message: 'Lead not found' });
  res.json({ success: true, data: lead });
});

exports.remove = asyncHandler(async (req, res) => {
  await Lead.findOneAndUpdate(
    { _id: req.params.id, organizationId: req.user.organizationId },
    { isActive: false }
  );
  res.json({ success: true, message: 'Lead deleted' });
});

exports.stats = asyncHandler(async (req, res) => {
  const orgId = req.user.organizationId;
  const byStatus = await Lead.aggregate([
    { $match: { organizationId: orgId, isActive: true } },
    { $group: { _id: '$status', count: { $sum: 1 } } },
  ]);
  const bySource = await Lead.aggregate([
    { $match: { organizationId: orgId, isActive: true } },
    { $group: { _id: '$source', count: { $sum: 1 } } },
  ]);
  const total = await Lead.countDocuments({ organizationId: orgId, isActive: true });
  res.json({ success: true, total, byStatus, bySource });
});
