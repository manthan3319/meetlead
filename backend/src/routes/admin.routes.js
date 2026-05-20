const router = require('express').Router();
const c = require('../controllers/admin.controller');
const { protect, adminOnly } = require('../middleware/auth');

router.use(protect, adminOnly);
router.get('/stats', c.stats);
router.get('/users', c.listUsers);
router.get('/users/:id', c.userDetail);
router.patch('/users/:id/toggle', c.toggleUser);
router.patch('/users/:id/role', c.updateUserRole);
router.get('/revenue-chart', c.revenueChart);

module.exports = router;
