const express = require('express');
const { getStats, getAllOrders, updateOrderStatus, createProduct } = require('../controllers/adminController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
// In production, add admin role check middleware here
router.use(authMiddleware);

router.get('/admin/stats', getStats);
router.get('/admin/orders', getAllOrders);
router.put('/admin/orders/:orderId', updateOrderStatus);
router.post('/admin/products', createProduct);

module.exports = router;
