const Subscription = require('../models/Subscription');

const requireActiveSubscription = async (req, res, next) => {
  try {
    if (['superadmin', 'admin'].includes(req.user.role)) return next();
    const sub = await Subscription.findOne({
      userId: req.user._id,
      status: { $in: ['active', 'trial'] },
      endDate: { $gt: new Date() },
    });
    if (!sub) {
      return res.status(403).json({ success: false, message: 'Active subscription required', code: 'NO_SUBSCRIPTION' });
    }
    req.subscription = sub;
    next();
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { requireActiveSubscription };
