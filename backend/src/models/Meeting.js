const mongoose = require('mongoose');

const meetingSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true, index: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    leadId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lead', index: true },

    title: { type: String, required: true },
    description: String,
    agenda: String,

    type: { type: String, enum: ['online', 'offline', 'call'], default: 'online' },
    meetingLink: String,
    location: String,

    scheduledAt: { type: Date, required: true, index: true },
    durationMinutes: { type: Number, default: 30 },
    endAt: Date,

    status: {
      type: String,
      enum: ['scheduled', 'in-progress', 'completed', 'cancelled', 'no-show', 'rescheduled'],
      default: 'scheduled',
      index: true,
    },

    notes: String,
    outcome: String,
    actionItems: [{ task: String, dueDate: Date, done: Boolean }],

    reminders: [{ minutesBefore: Number, sent: Boolean, type: { type: String, enum: ['notification', 'alarm'] } }],

    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

meetingSchema.pre('save', function (next) {
  if (this.scheduledAt && this.durationMinutes) {
    this.endAt = new Date(this.scheduledAt.getTime() + this.durationMinutes * 60000);
  }
  next();
});

module.exports = mongoose.model('Meeting', meetingSchema);
