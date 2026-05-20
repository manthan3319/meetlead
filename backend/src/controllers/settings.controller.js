const asyncHandler = require('../utils/asyncHandler');
const Setting = require('../models/Setting');
const { clearCache } = require('../services/razorpay.service');

const SECRET_KEYS = ['razorpay_key_secret'];

const sanitize = (item) => {
  const obj = item.toObject ? item.toObject() : item;
  if (SECRET_KEYS.includes(obj.key) && obj.value) {
    obj.value = '••••••' + String(obj.value).slice(-4);
    obj.hasValue = true;
  }
  return obj;
};

exports.list = asyncHandler(async (req, res) => {
  const items = await Setting.find();
  res.json({ success: true, data: items.map(sanitize) });
});

exports.publicList = asyncHandler(async (req, res) => {
  const items = await Setting.find({ isPublic: true });
  const map = {};
  items.forEach((i) => (map[i.key] = i.value));
  res.json({ success: true, data: map });
});

exports.get = asyncHandler(async (req, res) => {
  const item = await Setting.findOne({ key: req.params.key });
  if (!item) return res.status(404).json({ success: false, message: 'Setting not found' });
  res.json({ success: true, data: sanitize(item) });
});

exports.upsert = asyncHandler(async (req, res) => {
  const { key } = req.params;
  const { value, group, description, isPublic } = req.body;
  const update = { value };
  if (group !== undefined) update.group = group;
  if (description !== undefined) update.description = description;
  if (isPublic !== undefined) update.isPublic = isPublic;

  const item = await Setting.findOneAndUpdate({ key }, update, { upsert: true, new: true });
  if (key.startsWith('razorpay_')) clearCache();
  res.json({ success: true, data: sanitize(item) });
});

exports.bulkUpsert = asyncHandler(async (req, res) => {
  const { settings } = req.body;
  const results = [];
  for (const s of settings) {
    const item = await Setting.findOneAndUpdate(
      { key: s.key },
      { value: s.value, group: s.group, description: s.description, isPublic: s.isPublic },
      { upsert: true, new: true }
    );
    results.push(sanitize(item));
  }
  clearCache();
  res.json({ success: true, data: results });
});
