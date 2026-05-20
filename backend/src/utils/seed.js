require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Plan = require('../models/Plan');
const Setting = require('../models/Setting');
const Template = require('../models/Template');
const connectDB = require('../config/db');

const seed = async () => {
  await connectDB();
  console.log('🌱 Seeding...');

  const adminEmail = process.env.ADMIN_EMAIL || 'admin@meetlead.com';
  const adminPass = process.env.ADMIN_PASSWORD || 'Admin@123';

  let admin = await User.findOne({ email: adminEmail });
  if (!admin) {
    admin = await User.create({
      name: 'Super Admin',
      email: adminEmail,
      password: adminPass,
      role: 'superadmin',
      isActive: true,
    });
    console.log(`✅ Admin created: ${adminEmail} / ${adminPass}`);
  } else {
    console.log('ℹ️  Admin already exists');
  }

  const plans = [
    {
      name: 'Free Trial',
      slug: 'trial',
      description: '7-day free trial with all features',
      durationMonths: 0,
      price: 0,
      maxUsers: 1,
      maxLeads: 50,
      sortOrder: 0,
      features: [
        { name: 'Lead management', included: true },
        { name: 'Meeting scheduling', included: true },
        { name: 'Reminders + Alarms', included: true },
        { name: 'AI voice assistant', included: true },
      ],
    },
    {
      name: 'Starter',
      slug: 'starter',
      description: 'For solo professionals',
      durationMonths: 3,
      price: 999,
      maxUsers: 1,
      maxLeads: 500,
      sortOrder: 1,
      features: [
        { name: '1 user', included: true },
        { name: '500 leads', included: true },
        { name: 'Unlimited meetings', included: true },
        { name: 'Basic reminders', included: true },
        { name: 'AI voice assistant', included: false },
      ],
    },
    {
      name: 'Professional',
      slug: 'pro',
      description: 'For small teams',
      durationMonths: 6,
      price: 2499,
      maxUsers: 3,
      maxLeads: 2000,
      isPopular: true,
      sortOrder: 2,
      features: [
        { name: '3 users', included: true },
        { name: '2,000 leads', included: true },
        { name: 'AI voice assistant', included: true },
        { name: 'Advanced analytics', included: true },
        { name: 'Email automation', included: true },
      ],
    },
    {
      name: 'Business',
      slug: 'business',
      description: 'For growing agencies',
      durationMonths: 12,
      price: 4999,
      maxUsers: 10,
      maxLeads: 999999,
      sortOrder: 3,
      features: [
        { name: '10 users', included: true },
        { name: 'Unlimited leads', included: true },
        { name: 'All features', included: true },
        { name: 'Priority support', included: true },
        { name: 'White-label option', included: true },
      ],
    },
  ];

  for (const p of plans) {
    await Plan.findOneAndUpdate({ slug: p.slug }, p, { upsert: true, new: true });
  }
  console.log(`✅ ${plans.length} plans seeded`);

  const settings = [
    { key: 'site_name', value: 'MeetLead Pro', group: 'general', isPublic: true },
    { key: 'site_tagline', value: 'Never forget a meeting. Never lose a lead.', group: 'general', isPublic: true },
    { key: 'support_email', value: 'support@meetlead.com', group: 'general', isPublic: true },
    { key: 'support_phone', value: '+91-0000000000', group: 'general', isPublic: true },
    { key: 'razorpay_key_id', value: '', group: 'payment', description: 'Razorpay public key ID' },
    { key: 'razorpay_key_secret', value: '', group: 'payment', description: 'Razorpay secret key' },
    { key: 'currency', value: 'INR', group: 'payment', isPublic: true },
    { key: 'app_version', value: '1.0.0', group: 'general', isPublic: true },
  ];
  for (const s of settings) {
    await Setting.findOneAndUpdate({ key: s.key }, s, { upsert: true });
  }
  console.log(`✅ ${settings.length} settings seeded`);

  const templates = [
    {
      name: 'Initial WhatsApp Greeting',
      channel: 'whatsapp',
      body: 'Hi {{name}}, thanks for showing interest in our services. When can we connect for a quick chat?',
      variables: ['name'],
      isGlobal: true,
    },
    {
      name: 'Meeting Reminder',
      channel: 'whatsapp',
      body: 'Hi {{name}}, just a reminder that we have a meeting at {{time}}. See you soon!',
      variables: ['name', 'time'],
      isGlobal: true,
    },
    {
      name: 'Follow-up after Meeting',
      channel: 'whatsapp',
      body: 'Hi {{name}}, thanks for the meeting today. As discussed, I will share the proposal shortly.',
      variables: ['name'],
      isGlobal: true,
    },
  ];
  for (const t of templates) {
    await Template.findOneAndUpdate({ name: t.name, isGlobal: true }, t, { upsert: true });
  }
  console.log(`✅ ${templates.length} templates seeded`);

  console.log('🌱 Done seeding');
  mongoose.connection.close();
};

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
