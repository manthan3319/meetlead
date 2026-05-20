const router = require('express').Router();
const c = require('../controllers/lead.controller');
const { protect } = require('../middleware/auth');
const { requireActiveSubscription } = require('../middleware/subscription');

router.use(protect, requireActiveSubscription);
router.get('/stats', c.stats);
router.get('/', c.list);
router.post('/', c.create);
router.get('/:id', c.get);
router.put('/:id', c.update);
router.delete('/:id', c.remove);

module.exports = router;
