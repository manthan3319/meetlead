const router = require('express').Router();
const c = require('../controllers/reminder.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/pending', c.pending);
router.get('/', c.all);
router.post('/', c.create);
router.patch('/:id/seen', c.markSeen);

module.exports = router;
