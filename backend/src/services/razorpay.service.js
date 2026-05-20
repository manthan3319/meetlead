const Razorpay = require('razorpay');
const Setting = require('../models/Setting');

let cachedInstance = null;
let cachedAt = 0;

const getRazorpay = async () => {
  if (cachedInstance && Date.now() - cachedAt < 60_000) return cachedInstance;
  const keyId = await Setting.findOne({ key: 'razorpay_key_id' });
  const keySecret = await Setting.findOne({ key: 'razorpay_key_secret' });
  if (!keyId?.value || !keySecret?.value) {
    throw new Error('Razorpay keys not configured. Admin must add them in Settings.');
  }
  cachedInstance = new Razorpay({ key_id: keyId.value, key_secret: keySecret.value });
  cachedAt = Date.now();
  return cachedInstance;
};

const getPublicKey = async () => {
  const keyId = await Setting.findOne({ key: 'razorpay_key_id' });
  return keyId?.value || null;
};

const clearCache = () => {
  cachedInstance = null;
  cachedAt = 0;
};

module.exports = { getRazorpay, getPublicKey, clearCache };
