const mongoose = require('mongoose');

const callLogSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', index: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    leadId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lead', index: true },
    phone: String,
    direction: { type: String, enum: ['incoming', 'outgoing', 'missed'], default: 'outgoing' },
    disposition: {
      type: String,
      enum: ['connected', 'not-picked', 'wrong-number', 'busy', 'switched-off', 'callback'],
    },
    durationSeconds: Number,
    note: String,
    calledAt: Date,
  },
  { timestamps: true }
);

module.exports = mongoose.model('CallLog', callLogSchema);
