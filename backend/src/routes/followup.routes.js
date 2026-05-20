const router = require('express').Router();
const c = require('../controllers/followup.controller');
const { protect } = require('../middleware/auth');
const { requireActiveSubscription } = require('../middleware/subscription');

router.use(protect, requireActiveSubscription);
router.get('/today', c.today);
router.get('/', c.list);
router.post('/', c.create);
router.put('/:id', c.update);
router.patch('/:id/complete', c.complete);
router.delete('/:id', c.remove);

module.exports = router;
