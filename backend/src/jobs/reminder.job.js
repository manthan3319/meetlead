const cron = require('node-cron');
const Reminder = require('../models/Reminder');

let app;
const setApp = (a) => (app = a);

const tick = async (io) => {
  try {
    const now = new Date();
    const due = await Reminder.find({ sent: false, remindAt: { $lte: now } }).limit(200);
    for (const r of due) {
      if (io) io.to(`user:${r.userId}`).emit('reminder', r);
      r.sent = true;
      r.sentAt = now;
      await r.save();
    }
    if (due.length) console.log(`⏰ Dispatched ${due.length} reminder(s)`);
  } catch (e) {
    console.error('Reminder job error:', e.message);
  }
};

const start = () => {
  cron.schedule('* * * * *', () => {
    const io = global.ioRef;
    tick(io);
  });
  console.log('⏰ Reminder cron started (every minute)');
};

module.exports = { start, setApp };
