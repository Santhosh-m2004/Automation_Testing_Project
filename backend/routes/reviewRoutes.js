const express = require('express');
const { getProductReviews, addReview } = require('../controllers/reviewController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.get('/products/:productId/reviews', getProductReviews);
router.post('/products/:productId/reviews', authMiddleware, addReview);

module.exports = router;
