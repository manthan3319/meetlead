const router = require('express').Router();
const c = require('../controllers/settings.controller');
const { protect, adminOnly } = require('../middleware/auth');

router.get('/public', c.publicList);
router.use(protect, adminOnly);
router.get('/', c.list);
router.get('/:key', c.get);
router.put('/:key', c.upsert);
router.post('/bulk', c.bulkUpsert);

module.exports = router;
