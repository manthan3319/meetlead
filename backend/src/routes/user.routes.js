const router = require('express').Router();
const c = require('../controllers/user.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/team', c.teamList);
router.post('/invite', c.invite);
router.put('/:id', c.update);
router.patch('/:id/toggle', c.toggle);

module.exports = router;
