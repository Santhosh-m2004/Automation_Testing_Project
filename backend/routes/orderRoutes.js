const express = require('express');
const { createOrder, getOrders, getOrderById } = require('../controllers/orderController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.post('/order', createOrder);
router.get('/orders', getOrders);
router.get('/orders/:id', getOrderById);

module.exports = router;
