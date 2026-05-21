require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const http = require('http');
const { Server } = require('socket.io');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');

const connectDB = require('./config/db');
const { errorHandler, notFound } = require('./middleware/error');
const reminderJob = require('./jobs/reminder.job');

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const leadRoutes = require('./routes/lead.routes');
const meetingRoutes = require('./routes/meeting.routes');
const serviceRoutes = require('./routes/service.routes');
const followupRoutes = require('./routes/followup.routes');
const reminderRoutes = require('./routes/reminder.routes');
const templateRoutes = require('./routes/template.routes');
const planRoutes = require('./routes/plan.routes');
const subscriptionRoutes = require('./routes/subscription.routes');
const paymentRoutes = require('./routes/payment.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const adminRoutes = require('./routes/admin.routes');
const settingsRoutes = require('./routes/settings.routes');

const app = express();
app.disable('etag');
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: process.env.CLIENT_URL || '*', credentials: true },
});

app.set('io', io);

app.use(helmet());
app.use(cors({ origin: '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/uploads', express.static('uploads'));

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 300 });
app.use('/api', limiter);

app.get('/', (req, res) => {
  res.json({ name: 'MeetLead Pro API', version: '1.0.0', status: 'running', docs: '/api/docs' });
});

app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { explorer: true }));
app.get('/api/docs.json', (req, res) => res.json(swaggerSpec));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/leads', leadRoutes);
app.use('/api/meetings', meetingRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/followups', followupRoutes);
app.use('/api/reminders', reminderRoutes);
app.use('/api/templates', templateRoutes);
app.use('/api/plans', planRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/settings', settingsRoutes);

app.use(notFound);
app.use(errorHandler);

io.on('connection', (socket) => {
  socket.on('join', (userId) => socket.join(`user:${userId}`));
  socket.on('disconnect', () => {});
});

global.ioRef = io;

const PORT = process.env.PORT || 5000;

connectDB().then(() => {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 MeetLead API running on port ${PORT} (bound to 0.0.0.0)`);
    reminderJob.start();
  });
});
