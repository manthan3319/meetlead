const router = require('express').Router();
const c = require('../controllers/subscription.controller');
const { protect, adminOnly } = require('../middleware/auth');

router.use(protect);
router.get('/current', c.current);
router.get('/history', c.history);
router.get('/admin/all', adminOnly, c.adminList);
router.put('/admin/:id', adminOnly, c.adminUpdate);

module.exports = router;
