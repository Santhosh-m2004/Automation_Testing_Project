// Enhanced product controller with rating and pagination
const Product = require('../models/Product');
const Review = require('../models/Review');

// Helper to attach average rating
async function attachRatings(products) {
  const productsArray = Array.isArray(products) ? products : [products];
  for (let product of productsArray) {
    const result = await Review.aggregate([
      { $match: { product: product._id } },
      { $group: { _id: null, avgRating: { $avg: '$rating' }, count: { $sum: 1 } } }
    ]);
    product = product.toObject();
    product.averageRating = result.length ? result[0].avgRating : 0;
    product.reviewCount = result.length ? result[0].count : 0;
  }
  return productsArray;
}

// Override getAllProducts with pagination
exports.getAllProducts = async (req, res) => {
  try {
    const { search, category, page = 1, limit = 8 } = req.query;
    let filter = {};
    if (search && search.trim()) filter.name = { $regex: search, $options: 'i' };
    if (category && category !== 'all') filter.category = category;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const products = await Product.find(filter).skip(skip).limit(parseInt(limit));
    const total = await Product.countDocuments(filter);
    const productsWithRating = await attachRatings(products);
    res.json({
      products: productsWithRating,
      currentPage: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      totalProducts: total
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ message: 'Failed to fetch products' });
  }
};

// Override getProductById with rating
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    const [ratedProduct] = await attachRatings([product]);
    res.json(ratedProduct);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ message: 'Failed to fetch product' });
  }
};

// Keep original categories method unchanged
exports.getCategories = async (req, res) => {
  try {
    const categories = await Product.distinct('category');
    res.json(categories);
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ message: 'Failed to fetch categories' });
  }
};
