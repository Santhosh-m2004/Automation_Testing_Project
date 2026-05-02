const express = require('express');
const { getCart, addToCart, updateCartItem, removeCartItem } = require('../controllers/cartController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.get('/cart', getCart);
router.post('/cart/:productId', addToCart);
router.put('/cart/:productId', updateCartItem);
router.delete('/cart/:productId', removeCartItem);

module.exports = router;
