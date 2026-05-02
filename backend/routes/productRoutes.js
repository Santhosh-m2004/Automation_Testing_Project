const express = require('express');
const { getAllProducts, getProductById, getCategories } = require('../controllers/productController');

const router = express.Router();

router.get('/products', getAllProducts);
router.get('/products/:id', getProductById);
router.get('/categories', getCategories);

module.exports = router;
