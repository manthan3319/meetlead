const mongoose = require('mongoose');

const templateSchema = new mongoose.Schema(
  {
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', index: true },
    name: { type: String, required: true },
    channel: { type: String, enum: ['whatsapp', 'sms', 'email', 'note'], required: true },
    subject: String,
    body: { type: String, required: true },
    variables: [String],
    isGlobal: { type: Boolean, default: false },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Template', templateSchema);
