const mongoose = require('mongoose');

const leadSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true, index: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },

    name: { type: String, required: true, trim: true },
    phone: { type: String, trim: true, index: true },
    whatsapp: { type: String, trim: true },
    email: { type: String, trim: true, lowercase: true },
    company: String,
    address: String,

    source: {
      type: String,
      enum: ['whatsapp', 'call', 'website', 'instagram', 'facebook', 'referral', 'walk-in', 'other'],
      default: 'other',
    },
    status: {
      type: String,
      enum: ['new', 'contacted', 'qualified', 'proposal', 'negotiation', 'won', 'lost'],
      default: 'new',
      index: true,
    },
    priority: { type: String, enum: ['hot', 'warm', 'cold'], default: 'warm' },

    requirement: String,
    services: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Service' }],
    estimatedValue: Number,

    tags: [String],
    notes: String,
    lastContactedAt: Date,
    nextFollowupAt: Date,

    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

leadSchema.index({ organizationId: 1, status: 1 });

module.exports = mongoose.model('Lead', leadSchema);
