const router = require('express').Router();
const c = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth');

router.post('/register', c.register);
router.post('/login', c.login);
router.get('/me', protect, c.me);
router.put('/me', protect, c.updateProfile);
router.put('/change-password', protect, c.changePassword);

module.exports = router;
