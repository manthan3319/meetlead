const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true, index: true },
    name: { type: String, required: true },
    category: {
      type: String,
      enum: ['website', 'graphics', 'marketing', 'development', 'consulting', 'other'],
      default: 'other',
    },
    description: String,
    price: Number,
    currency: { type: String, default: 'INR' },
    deliveryDays: Number,
    deliverables: [String],
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Service', serviceSchema);
