const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    phone: { type: String, trim: true },
    password: { type: String, required: true, select: false },
    role: {
      type: String,
      enum: ['superadmin', 'admin', 'owner', 'manager', 'sales', 'calling', 'support'],
      default: 'owner',
    },
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization' },
    avatar: String,
    isActive: { type: Boolean, default: true },
    lastLoginAt: Date,
    fcmToken: String,
    preferences: {
      language: { type: String, default: 'en' },
      reminderSound: { type: String, default: 'default' },
      voiceAssistant: { type: Boolean, default: true },
    },
  },
  { timestamps: true }
);

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.matchPassword = function (entered) {
  return bcrypt.compare(entered, this.password);
};

module.exports = mongoose.model('User', userSchema);
