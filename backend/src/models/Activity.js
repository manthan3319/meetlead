const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', index: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    refType: String,
    refId: mongoose.Schema.Types.ObjectId,
    action: String,
    description: String,
    meta: Object,
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);
