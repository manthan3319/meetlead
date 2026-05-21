const router = require('express').Router();
const c = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth');

/**
 * @openapi
 * /api/auth/register:
 *   post:
 *     tags: [Auth]
 *     summary: Register a new owner account
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, password]
 *             properties:
 *               name:     { type: string, example: Jane Doe }
 *               email:    { type: string, format: email, example: jane@acme.com }
 *               phone:    { type: string, example: "+91 98765 43210" }
 *               password: { type: string, format: password, example: Secret@123 }
 *               orgName:  { type: string, example: Acme Inc. }
 *     responses:
 *       201:
 *         description: Account created, returns JWT
 *         content:
 *           application/json:
 *             schema: { $ref: '#/components/schemas/AuthResponse' }
 *       400:
 *         description: Validation error or email already registered
 *         content:
 *           application/json:
 *             schema: { $ref: '#/components/schemas/Error' }
 */
router.post('/register', c.register);

/**
 * @openapi
 * /api/auth/login:
 *   post:
 *     tags: [Auth]
 *     summary: Log in with email and password
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:    { type: string, format: email }
 *               password: { type: string, format: password }
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema: { $ref: '#/components/schemas/AuthResponse' }
 *       401: { description: Invalid credentials }
 *       403: { description: Account disabled }
 */
router.post('/login', c.login);

/**
 * @openapi
 * /api/auth/me:
 *   get:
 *     tags: [Auth]
 *     summary: Get the currently authenticated user
 *     responses:
 *       200: { description: Current user object }
 *       401: { description: Unauthorized }
 */
router.get('/me', protect, c.me);

/**
 * @openapi
 * /api/auth/me:
 *   put:
 *     tags: [Auth]
 *     summary: Update the current user's profile
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:        { type: string }
 *               phone:       { type: string }
 *               avatar:      { type: string }
 *               preferences: { type: object }
 *               fcmToken:    { type: string }
 *     responses:
 *       200: { description: Updated user }
 *       401: { description: Unauthorized }
 */
router.put('/me', protect, c.updateProfile);

/**
 * @openapi
 * /api/auth/change-password:
 *   put:
 *     tags: [Auth]
 *     summary: Change the current user's password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [current, next]
 *             properties:
 *               current: { type: string, format: password }
 *               next:    { type: string, format: password }
 *     responses:
 *       200: { description: Password changed }
 *       400: { description: Current password incorrect }
 *       401: { description: Unauthorized }
 */
router.put('/change-password', protect, c.changePassword);

module.exports = router;
