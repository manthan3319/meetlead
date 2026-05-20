const router = require('express').Router();
const c = require('../controllers/payment.controller');
const { protect, adminOnly } = require('../middleware/auth');

router.get('/config', c.config);
router.use(protect);
router.post('/order', c.createOrder);
router.post('/verify', c.verify);
router.get('/history', c.history);
router.get('/admin/all', adminOnly, c.adminList);

module.exports = router;
