const router = require('express').Router();
const c = require('../controllers/meeting.controller');
const { protect } = require('../middleware/auth');
const { requireActiveSubscription } = require('../middleware/subscription');

router.use(protect, requireActiveSubscription);
router.get('/upcoming', c.upcoming);
router.get('/', c.list);
router.post('/', c.create);
router.get('/:id', c.get);
router.put('/:id', c.update);
router.delete('/:id', c.remove);
router.put('/:id/note', c.addNote);

module.exports = router;
