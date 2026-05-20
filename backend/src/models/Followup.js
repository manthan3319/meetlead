const mongoose = require('mongoose');

const followupSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true, index: true },
    leadId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lead', required: true, index: true },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },

    type: { type: String, enum: ['call', 'whatsapp', 'email', 'meeting', 'visit'], default: 'call' },
    scheduledAt: { type: Date, required: true, index: true },
    note: String,
    templateId: { type: mongoose.Schema.Types.ObjectId, ref: 'Template' },

    status: { type: String, enum: ['pending', 'done', 'skipped'], default: 'pending', index: true },
    completedAt: Date,
    outcome: String,
  },
  { timestamps: true }
);

module.exports = mongoose.model('Followup', followupSchema);
