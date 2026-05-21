const swaggerJSDoc = require('swagger-jsdoc');
const path = require('path');

const options = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'MeetLead Pro API',
      version: '1.0.0',
      description:
        'REST API for MeetLead Pro — lead, meeting, follow-up, subscription & payment management.',
    },
    servers: [
      { url: 'http://localhost:5000', description: 'Local development' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: 'Something went wrong' },
          },
        },
        AuthResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            token: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...' },
            user: {
              type: 'object',
              properties: {
                id: { type: 'string' },
                name: { type: 'string' },
                email: { type: 'string' },
                role: { type: 'string', enum: ['owner', 'admin', 'agent'] },
                organizationId: { type: 'string' },
              },
            },
            subscription: { type: 'object', nullable: true },
          },
        },
      },
    },
    security: [{ bearerAuth: [] }],
    tags: [
      { name: 'Auth', description: 'Registration, login, profile' },
      { name: 'Users', description: 'User management' },
      { name: 'Leads', description: 'Lead CRUD & assignment' },
      { name: 'Meetings', description: 'Meeting scheduling' },
      { name: 'Services', description: 'Service catalog' },
      { name: 'Followups', description: 'Follow-up tracking' },
      { name: 'Reminders', description: 'Reminders & notifications' },
      { name: 'Templates', description: 'Message templates' },
      { name: 'Plans', description: 'Subscription plans' },
      { name: 'Subscriptions', description: 'Org subscriptions' },
      { name: 'Payments', description: 'Razorpay payments' },
      { name: 'Dashboard', description: 'Aggregate metrics' },
      { name: 'Admin', description: 'Platform admin' },
      { name: 'Settings', description: 'Org & user settings' },
    ],
  },
  apis: [path.join(__dirname, '..', 'routes', '*.js')],
};

module.exports = swaggerJSDoc(options);
