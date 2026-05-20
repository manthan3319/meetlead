const router = require('express').Router();
const c = require('../controllers/dashboard.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/summary', c.summary);
router.get('/pipeline', c.pipeline);

module.exports = router;
