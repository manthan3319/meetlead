const asyncHandler = require('../utils/asyncHandler');
const Lead = require('../models/Lead');
const Meeting = require('../models/Meeting');
const Followup = require('../models/Followup');

exports.summary = asyncHandler(async (req, res) => {
  const orgId = req.user.organizationId;
  const now = new Date();
  const startOfDay = new Date(now.setHours(0, 0, 0, 0));
  const endOfDay = new Date(new Date().setHours(23, 59, 59, 999));

  const [
    totalLeads,
    newLeads,
    todayMeetings,
    upcomingMeetings,
    todayFollowups,
    pendingFollowups,
    wonLeads,
  ] = await Promise.all([
    Lead.countDocuments({ organizationId: orgId, isActive: true }),
    Lead.countDocuments({ organizationId: orgId, isActive: true, status: 'new' }),
    Meeting.countDocuments({
      organizationId: orgId,
      isActive: true,
      scheduledAt: { $gte: startOfDay, $lte: endOfDay },
    }),
    Meeting.countDocuments({
      organizationId: orgId,
      isActive: true,
      status: 'scheduled',
      scheduledAt: { $gt: now },
    }),
    Followup.countDocuments({
      organizationId: orgId,
      status: 'pending',
      scheduledAt: { $gte: startOfDay, $lte: endOfDay },
    }),
    Followup.countDocuments({ organizationId: orgId, status: 'pending' }),
    Lead.countDocuments({ organizationId: orgId, isActive: true, status: 'won' }),
  ]);

  res.json({
    success: true,
    data: {
      leads: { total: totalLeads, new: newLeads, won: wonLeads },
      meetings: { today: todayMeetings, upcoming: upcomingMeetings },
      followups: { today: todayFollowups, pending: pendingFollowups },
    },
  });
});

exports.pipeline = asyncHandler(async (req, res) => {
  const pipeline = await Lead.aggregate([
    { $match: { organizationId: req.user.organizationId, isActive: true } },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 },
        value: { $sum: '$estimatedValue' },
      },
    },
  ]);
  res.json({ success: true, data: pipeline });
});
