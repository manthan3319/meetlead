const mongoose = require('mongoose');

const reminderSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true, index: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    refType: { type: String, enum: ['meeting', 'followup', 'task', 'custom'], required: true },
    refId: { type: mongoose.Schema.Types.ObjectId, index: true },
    title: { type: String, required: true },
    body: String,
    remindAt: { type: Date, required: true, index: true },
    style: { type: String, enum: ['notification', 'alarm'], default: 'notification' },
    sent: { type: Boolean, default: false, index: true },
    sentAt: Date,
    seen: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Reminder', reminderSchema);
