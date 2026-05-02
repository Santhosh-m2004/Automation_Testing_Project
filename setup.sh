#!/bin/bash

# Create project directory structure
mkdir -p backend/{models,routes,controllers,middleware,config}
mkdir -p frontend/{css,js}

# Create backend package.json
cat > backend/package.json << 'EOF'
{
  "name": "ecommerce-backend",
  "version": "1.0.0",
  "description": "Full-featured e-commerce backend for automation testing",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

# Create backend .env file
cat > backend/.env << 'EOF'
PORT=5000
MONGODB_URI=mongodb://localhost:27017/ecommerce
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
EOF

# Create backend server.js
cat > backend/server.js << 'EOF'
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

// Import routes
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// Database connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('MongoDB connected successfully');
    // Seed products if empty
    const Product = require('./models/Product');
    Product.seedProducts();
  })
  .catch(err => console.error('MongoDB connection error:', err));

// API Routes
app.use('/api', authRoutes);
app.use('/api', productRoutes);
app.use('/api', cartRoutes);
app.use('/api', orderRoutes);

// Serve frontend for any non-API route
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Create backend config/db.js
cat > backend/config/db.js << 'EOF'
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');
  } catch (error) {
    console.error('Database connection failed:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
EOF

# Create backend models/User.js
cat > backend/models/User.js << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const cartItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1,
    default: 1
  }
});

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  cart: [cartItemSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
EOF

# Create backend models/Product.js
cat > backend/models/Product.js << 'EOF'
const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  imageUrl: {
    type: String,
    required: true
  },
  category: {
    type: String,
    default: 'General'
  },
  stock: {
    type: Number,
    default: 100
  }
});

// Sample products with categories
const sampleProducts = [
  {
    name: "Wireless Bluetooth Headphones",
    description: "High-quality wireless headphones with noise cancellation and 20hr battery life.",
    price: 79.99,
    imageUrl: "https://picsum.photos/id/1/300/300",
    category: "Electronics"
  },
  {
    name: "Smart Watch Pro",
    description: "Fitness tracker with heart rate monitor, GPS, and waterproof design.",
    price: 199.99,
    imageUrl: "https://picsum.photos/id/2/300/300",
    category: "Electronics"
  },
  {
    name: "Ergonomic Office Chair",
    description: "Comfortable mesh office chair with lumbar support and adjustable height.",
    price: 249.99,
    imageUrl: "https://picsum.photos/id/20/300/300",
    category: "Furniture"
  },
  {
    name: "USB-C Laptop Dock",
    description: "7-in-1 multiport adapter with HDMI, USB 3.0, and Ethernet port.",
    price: 49.99,
    imageUrl: "https://picsum.photos/id/26/300/300",
    category: "Electronics"
  },
  {
    name: "Cotton T-Shirt - Pack of 3",
    description: "Soft cotton blend t-shirts, breathable and comfortable for daily wear.",
    price: 24.99,
    imageUrl: "https://picsum.photos/id/28/300/300",
    category: "Clothing"
  },
  {
    name: "Stainless Steel Water Bottle",
    description: "Insulated water bottle keeps drinks cold for 24 hours or hot for 12 hours.",
    price: 19.99,
    imageUrl: "https://picsum.photos/id/29/300/300",
    category: "Accessories"
  },
  {
    name: "Mechanical Gaming Keyboard",
    description: "RGB backlit mechanical keyboard with blue switches and anti-ghosting.",
    price: 89.99,
    imageUrl: "https://picsum.photos/id/30/300/300",
    category: "Electronics"
  },
  {
    name: "Ceramic Coffee Mug",
    description: "15oz large ceramic mug with ergonomic handle, microwave and dishwasher safe.",
    price: 12.99,
    imageUrl: "https://picsum.photos/id/31/300/300",
    category: "Kitchen"
  },
  {
    name: "Yoga Mat Non-Slip",
    description: "Eco-friendly non-slip yoga mat with carrying strap, 6mm thickness.",
    price: 29.99,
    imageUrl: "https://picsum.photos/id/32/300/300",
    category: "Sports"
  },
  {
    name: "LED Desk Lamp",
    description: "Adjustable desk lamp with 5 brightness levels and USB charging port.",
    price: 34.99,
    imageUrl: "https://picsum.photos/id/33/300/300",
    category: "Home"
  }
];

// Static method to seed products
productSchema.statics.seedProducts = async function() {
  const count = await this.countDocuments();
  if (count === 0) {
    console.log('Seeding sample products...');
    await this.insertMany(sampleProducts);
    console.log('Sample products seeded successfully');
  }
};

module.exports = mongoose.model('Product', productSchema);
EOF

# Create backend models/Order.js
cat > backend/models/Order.js << 'EOF'
const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  name: String,
  price: Number,
  quantity: Number
});

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [orderItemSchema],
  totalAmount: {
    type: Number,
    required: true
  },
  address: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Order', orderSchema);
EOF

# Create backend middleware/auth.js
cat > backend/middleware/auth.js << 'EOF'
const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ message: 'No token, authorization denied' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    console.error('Auth error:', error);
    res.status(401).json({ message: 'Token is not valid' });
  }
};

module.exports = authMiddleware;
EOF

# Create backend controllers/authController.js
cat > backend/controllers/authController.js << 'EOF'
const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// Register new user
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }
    
    const user = new User({ name, email, password });
    await user.save();
    
    const token = generateToken(user._id);
    
    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: { id: user._id, name: user.name, email: user.email }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

// Login user
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    
    const token = generateToken(user._id);
    
    res.json({
      message: 'Login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
};

// Get current user profile with order count
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const Order = require('../models/Order');
    const orderCount = await Order.countDocuments({ user: req.userId });
    res.json({ ...user.toObject(), orderCount });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
EOF

# Create backend controllers/productController.js
cat > backend/controllers/productController.js << 'EOF'
const Product = require('../models/Product');

// Get all products with optional search and category filter
exports.getAllProducts = async (req, res) => {
  try {
    const { search, category } = req.query;
    let filter = {};
    
    if (search && search.trim()) {
      filter.name = { $regex: search, $options: 'i' };
    }
    
    if (category && category !== 'all') {
      filter.category = category;
    }
    
    const products = await Product.find(filter);
    res.json(products);
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ message: 'Failed to fetch products' });
  }
};

// Get single product by ID
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ message: 'Failed to fetch product' });
  }
};

// Get all unique categories
exports.getCategories = async (req, res) => {
  try {
    const categories = await Product.distinct('category');
    res.json(categories);
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ message: 'Failed to fetch categories' });
  }
};
EOF

# Create backend controllers/cartController.js (unchanged but fully included)
cat > backend/controllers/cartController.js << 'EOF'
const User = require('../models/User');
const Product = require('../models/Product');

exports.getCart = async (req, res) => {
  try {
    const user = await User.findById(req.userId).populate('cart.productId');
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const cartItems = user.cart.map(item => ({
      productId: item.productId._id,
      name: item.productId.name,
      price: item.productId.price,
      imageUrl: item.productId.imageUrl,
      quantity: item.quantity,
      totalPrice: item.quantity * item.productId.price
    }));
    
    const totalAmount = cartItems.reduce((sum, item) => sum + item.totalPrice, 0);
    res.json({ items: cartItems, totalAmount });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ message: 'Failed to get cart' });
  }
};

exports.addToCart = async (req, res) => {
  try {
    const { productId } = req.params;
    const { quantity = 1 } = req.body;
    
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const cartItemIndex = user.cart.findIndex(item => item.productId.toString() === productId);
    if (cartItemIndex > -1) {
      user.cart[cartItemIndex].quantity += quantity;
    } else {
      user.cart.push({ productId, quantity });
    }
    
    await user.save();
    res.json({ message: 'Product added to cart successfully' });
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ message: 'Failed to add to cart' });
  }
};

exports.updateCartItem = async (req, res) => {
  try {
    const { productId } = req.params;
    const { quantity } = req.body;
    if (quantity < 1) return res.status(400).json({ message: 'Quantity must be at least 1' });
    
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const cartItem = user.cart.find(item => item.productId.toString() === productId);
    if (!cartItem) return res.status(404).json({ message: 'Item not found in cart' });
    
    cartItem.quantity = quantity;
    await user.save();
    res.json({ message: 'Cart updated successfully' });
  } catch (error) {
    console.error('Update cart error:', error);
    res.status(500).json({ message: 'Failed to update cart' });
  }
};

exports.removeCartItem = async (req, res) => {
  try {
    const { productId } = req.params;
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    user.cart = user.cart.filter(item => item.productId.toString() !== productId);
    await user.save();
    res.json({ message: 'Item removed from cart' });
  } catch (error) {
    console.error('Remove cart error:', error);
    res.status(500).json({ message: 'Failed to remove item' });
  }
};
EOF

# Create backend controllers/orderController.js
cat > backend/controllers/orderController.js << 'EOF'
const User = require('../models/User');
const Order = require('../models/Order');

exports.createOrder = async (req, res) => {
  try {
    const { address, phone } = req.body;
    if (!address || !phone) {
      return res.status(400).json({ message: 'Address and phone are required' });
    }
    
    const user = await User.findById(req.userId).populate('cart.productId');
    if (!user) return res.status(404).json({ message: 'User not found' });
    if (user.cart.length === 0) return res.status(400).json({ message: 'Cart is empty' });
    
    const orderItems = user.cart.map(item => ({
      productId: item.productId._id,
      name: item.productId.name,
      price: item.productId.price,
      quantity: item.quantity
    }));
    
    const totalAmount = orderItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
    
    const order = new Order({
      user: user._id,
      items: orderItems,
      totalAmount,
      address,
      phone
    });
    
    await order.save();
    user.cart = [];
    await user.save();
    
    res.status(201).json({ message: 'Order placed successfully', orderId: order._id, order });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ message: 'Failed to create order' });
  }
};

exports.getOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.userId }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
};

exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, user: req.userId });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ message: 'Failed to fetch order' });
  }
};
EOF

# Create backend routes/authRoutes.js
cat > backend/routes/authRoutes.js << 'EOF'
const express = require('express');
const { register, login, getMe } = require('../controllers/authController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me', authMiddleware, getMe);

module.exports = router;
EOF

# Create backend routes/productRoutes.js
cat > backend/routes/productRoutes.js << 'EOF'
const express = require('express');
const { getAllProducts, getProductById, getCategories } = require('../controllers/productController');

const router = express.Router();

router.get('/products', getAllProducts);
router.get('/products/:id', getProductById);
router.get('/categories', getCategories);

module.exports = router;
EOF

# Create backend routes/cartRoutes.js (unchanged)
cat > backend/routes/cartRoutes.js << 'EOF'
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
EOF

# Create backend routes/orderRoutes.js (add order detail)
cat > backend/routes/orderRoutes.js << 'EOF'
const express = require('express');
const { createOrder, getOrders, getOrderById } = require('../controllers/orderController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.post('/order', createOrder);
router.get('/orders', getOrders);
router.get('/orders/:id', getOrderById);

module.exports = router;
EOF

# ======================= FRONTEND FILES =======================

# frontend/index.html (updated with search and category filter)
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ShopHub - Your Online Store</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <!-- Search and Filter Bar -->
    <div class="search-filter-bar">
      <input type="text" id="searchInput" placeholder="Search products..." class="search-input">
      <select id="categoryFilter" class="category-select">
        <option value="all">All Categories</option>
      </select>
      <button id="searchBtn" class="btn btn-primary"><i class="fas fa-search"></i> Search</button>
    </div>

    <h1 class="page-title">Featured Products</h1>
    <div id="productGrid" class="product-grid">
      <div class="loading">Loading products...</div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/index.js"></script>
</body>
</html>
EOF

# frontend/product.html (unchanged)
cat > frontend/product.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Product Details - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <div id="productDetail" class="product-detail">
      <div class="loading">Loading product details...</div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/product.js"></script>
</body>
</html>
EOF

# frontend/cart.html (unchanged)
cat > frontend/cart.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Cart - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link active"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <h1 class="page-title">Shopping Cart</h1>
    <div id="cartContainer">
      <div class="loading">Loading cart...</div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/cart.js"></script>
</body>
</html>
EOF

# frontend/checkout.html (unchanged)
cat > frontend/checkout.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Checkout - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <h1 class="page-title">Checkout</h1>
    <div class="checkout-container">
      <div class="checkout-form-container">
        <form id="checkoutForm" class="checkout-form">
          <div class="form-group">
            <label for="address">Delivery Address</label>
            <textarea id="address" name="address" rows="3" required placeholder="Enter your full address"></textarea>
          </div>
          <div class="form-group">
            <label for="phone">Phone Number</label>
            <input type="tel" id="phone" name="phone" required placeholder="Enter your phone number">
          </div>
          <button type="submit" class="btn btn-primary btn-block">Place Order</button>
        </form>
      </div>
      <div class="order-summary">
        <h3>Order Summary</h3>
        <div id="orderSummaryItems"></div>
        <div class="summary-total">
          <span>Total:</span>
          <span id="orderTotal">$0.00</span>
        </div>
      </div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/checkout.js"></script>
</body>
</html>
EOF

# frontend/login.html (unchanged)
cat > frontend/login.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container auth-container">
    <div class="auth-card">
      <h2>Login to ShopHub</h2>
      <form id="loginForm">
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Login</button>
      </form>
      <p class="auth-footer">Don't have an account? <a href="/register.html">Register here</a></p>
      <div id="loginMessage" class="message"></div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/auth.js"></script>
</body>
</html>
EOF

# frontend/register.html (unchanged)
cat > frontend/register.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container auth-container">
    <div class="auth-card">
      <h2>Create Account</h2>
      <form id="registerForm">
        <div class="form-group">
          <label for="name">Full Name</label>
          <input type="text" id="name" name="name" required>
        </div>
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required minlength="6">
        </div>
        <button type="submit" class="btn btn-primary btn-block">Register</button>
      </form>
      <p class="auth-footer">Already have an account? <a href="/login.html">Login here</a></p>
      <div id="registerMessage" class="message"></div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/auth.js"></script>
</body>
</html>
EOF

# NEW: orders.html (order history page)
cat > frontend/orders.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Orders - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <h1 class="page-title">My Orders</h1>
    <div id="ordersContainer">
      <div class="loading">Loading orders...</div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/orders.js"></script>
</body>
</html>
EOF

# NEW: profile.html (user profile page)
cat > frontend/profile.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Profile - ShopHub</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
  <nav class="navbar">
    <div class="nav-container">
      <a href="/" class="nav-logo">ShopHub</a>
      <div class="nav-links">
        <a href="/" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="/cart.html" class="nav-link"><i class="fas fa-shopping-cart"></i> Cart</a>
        <div id="authLinks"></div>
      </div>
    </div>
  </nav>

  <main class="container">
    <h1 class="page-title">My Profile</h1>
    <div id="profileContainer" class="profile-container">
      <div class="loading">Loading profile...</div>
    </div>
  </main>

  <script src="/js/main.js"></script>
  <script src="/js/profile.js"></script>
</body>
</html>
EOF

# frontend/css/style.css (updated with new styles)
cat > frontend/css/style.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f5f5f5;
  color: #333;
}

.navbar {
  background-color: #232f3e;
  color: white;
  padding: 1rem 2rem;
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-logo {
  font-size: 1.5rem;
  font-weight: bold;
  color: white;
  text-decoration: none;
}

.nav-links {
  display: flex;
  gap: 1.5rem;
  align-items: center;
  flex-wrap: wrap;
}

.nav-link {
  color: white;
  text-decoration: none;
  transition: color 0.3s;
}

.nav-link:hover, .nav-link.active {
  color: #ff9900;
}

.container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}

/* Search & Filter Bar */
.search-filter-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  align-items: center;
  background: white;
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 1px 5px rgba(0,0,0,0.1);
}

.search-input {
  flex: 1;
  padding: 0.6rem 1rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  min-width: 180px;
}

.category-select {
  padding: 0.6rem 1rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  min-width: 150px;
}

/* Product Grid */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 1rem;
}

.product-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  transition: transform 0.3s, box-shadow 0.3s;
  cursor: pointer;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 20px rgba(0,0,0,0.15);
}

.product-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.product-info {
  padding: 1rem;
}

.product-name {
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
  color: #333;
}

.product-price {
  font-size: 1.3rem;
  font-weight: bold;
  color: #b12704;
  margin-bottom: 0.5rem;
}

.product-description {
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 1rem;
  line-height: 1.4;
}

/* Buttons */
.btn {
  display: inline-block;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
  text-decoration: none;
  text-align: center;
}

.btn-primary {
  background-color: #ff9900;
  color: #232f3e;
}

.btn-primary:hover {
  background-color: #ffb340;
}

.btn-secondary {
  background-color: #232f3e;
  color: white;
}

.btn-secondary:hover {
  background-color: #3a4a5e;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-danger:hover {
  background-color: #c82333;
}

.btn-block {
  width: 100%;
}

/* Product Detail */
.product-detail {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.product-detail-image {
  width: 100%;
  border-radius: 8px;
}

.product-detail-info h1 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.product-detail-price {
  font-size: 1.8rem;
  color: #b12704;
  margin: 1rem 0;
}

.quantity-selector {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin: 1rem 0;
}

.quantity-selector input {
  width: 60px;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

/* Cart Page */
.cart-container {
  background: white;
  border-radius: 8px;
  padding: 1rem;
}

.cart-item {
  display: grid;
  grid-template-columns: 100px 1fr auto auto auto;
  gap: 1rem;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #eee;
}

.cart-item-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
}

.cart-item-details h3 {
  margin-bottom: 0.5rem;
}

.cart-item-price {
  color: #b12704;
  font-weight: bold;
}

.cart-item-quantity {
  width: 60px;
  padding: 0.3rem;
}

.cart-summary {
  margin-top: 1rem;
  padding: 1rem;
  text-align: right;
  border-top: 2px solid #eee;
}

.cart-total {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 1rem 0;
}

.empty-cart {
  text-align: center;
  padding: 3rem;
  color: #666;
}

/* Checkout */
.checkout-container {
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 2rem;
}

.checkout-form {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
}

.order-summary {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  height: fit-content;
}

.summary-total {
  font-size: 1.2rem;
  font-weight: bold;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 2px solid #eee;
  display: flex;
  justify-content: space-between;
}

/* Orders Page */
.order-card {
  background: white;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  box-shadow: 0 1px 5px rgba(0,0,0,0.1);
}

.order-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.order-id {
  font-weight: bold;
  color: #232f3e;
}

.order-status {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: bold;
}

.status-pending { background: #ffc107; color: #212529; }
.status-confirmed { background: #17a2b8; color: white; }
.status-shipped { background: #007bff; color: white; }
.status-delivered { background: #28a745; color: white; }
.status-cancelled { background: #dc3545; color: white; }

.order-items {
  margin: 1rem 0;
}

.order-item {
  display: flex;
  justify-content: space-between;
  padding: 0.3rem 0;
}

.order-total {
  text-align: right;
  font-weight: bold;
  font-size: 1.1rem;
  margin-top: 0.5rem;
}

/* Profile Page */
.profile-container {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  max-width: 600px;
  margin: 0 auto;
}

.profile-info p {
  margin: 0.8rem 0;
  font-size: 1.1rem;
}

.profile-label {
  font-weight: bold;
  color: #555;
  display: inline-block;
  width: 120px;
}

/* Forms */
.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 70vh;
}

.auth-card {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  width: 100%;
  max-width: 400px;
}

.auth-card h2 {
  margin-bottom: 1.5rem;
  text-align: center;
}

.auth-footer {
  text-align: center;
  margin-top: 1rem;
}

.message {
  margin-top: 1rem;
  padding: 0.5rem;
  border-radius: 4px;
  text-align: center;
}

.error-message {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.success-message {
  background-color: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: #666;
}

/* Responsive */
@media (max-width: 768px) {
  .product-detail {
    grid-template-columns: 1fr;
  }
  .cart-item {
    grid-template-columns: 1fr;
    text-align: center;
  }
  .checkout-container {
    grid-template-columns: 1fr;
  }
  .product-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
  .search-filter-bar {
    flex-direction: column;
    align-items: stretch;
  }
  .order-header {
    flex-direction: column;
    gap: 0.5rem;
  }
}
EOF

# frontend/js/main.js (updated navbar with orders and profile)
cat > frontend/js/main.js << 'EOF'
// Global helper functions

const API_BASE = '/api';

function getToken() {
  return localStorage.getItem('token');
}

function setToken(token) {
  if (token) {
    localStorage.setItem('token', token);
  } else {
    localStorage.removeItem('token');
  }
}

function getCurrentUser() {
  const userStr = localStorage.getItem('user');
  if (userStr) {
    try {
      return JSON.parse(userStr);
    } catch (e) {
      return null;
    }
  }
  return null;
}

function setCurrentUser(user) {
  if (user) {
    localStorage.setItem('user', JSON.stringify(user));
  } else {
    localStorage.removeItem('user');
  }
}

function isLoggedIn() {
  return !!getToken();
}

function logout() {
  setToken(null);
  setCurrentUser(null);
  window.location.href = '/';
}

async function apiRequest(url, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  const response = await fetch(`${API_BASE}${url}`, {
    ...options,
    headers
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }
  return data;
}

function showMessage(elementId, message, isError = true) {
  const element = document.getElementById(elementId);
  if (element) {
    element.textContent = message;
    element.className = `message ${isError ? 'error-message' : 'success-message'}`;
    setTimeout(() => {
      element.textContent = '';
      element.className = 'message';
    }, 3000);
  }
}

function formatPrice(price) {
  return `$${price.toFixed(2)}`;
}

function updateNavbar() {
  const authLinks = document.getElementById('authLinks');
  if (!authLinks) return;
  
  if (isLoggedIn()) {
    const user = getCurrentUser();
    authLinks.innerHTML = `
      <a href="/profile.html" class="nav-link"><i class="fas fa-user"></i> Profile</a>
      <a href="/orders.html" class="nav-link"><i class="fas fa-box"></i> Orders</a>
      <span class="nav-link">Hello, ${user ? user.name : 'User'}</span>
      <a href="#" onclick="logout(); return false;" class="nav-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
    `;
  } else {
    authLinks.innerHTML = `
      <a href="/login.html" class="nav-link"><i class="fas fa-sign-in-alt"></i> Login</a>
    `;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  updateNavbar();
});
EOF

# frontend/js/index.js (updated with search and category filter)
cat > frontend/js/index.js << 'EOF'
let currentSearch = '';
let currentCategory = 'all';

async function loadCategories() {
  try {
    const categories = await apiRequest('/categories');
    const select = document.getElementById('categoryFilter');
    if (select) {
      const optionAll = select.querySelector('option[value="all"]');
      select.innerHTML = '<option value="all">All Categories</option>';
      categories.forEach(cat => {
        select.innerHTML += `<option value="${cat}">${cat}</option>`;
      });
    }
  } catch (error) {
    console.error('Error loading categories:', error);
  }
}

async function loadProducts() {
  const productGrid = document.getElementById('productGrid');
  productGrid.innerHTML = '<div class="loading">Loading products...</div>';
  
  try {
    let url = '/products?';
    if (currentSearch) url += `search=${encodeURIComponent(currentSearch)}&`;
    if (currentCategory && currentCategory !== 'all') url += `category=${encodeURIComponent(currentCategory)}&`;
    
    const products = await apiRequest(url);
    
    if (products.length === 0) {
      productGrid.innerHTML = '<div class="empty-cart">No products found</div>';
      return;
    }
    
    productGrid.innerHTML = products.map(product => `
      <div class="product-card" data-product-id="${product._id}">
        <img src="${product.imageUrl}" alt="${product.name}" class="product-image">
        <div class="product-info">
          <h3 class="product-name">${product.name}</h3>
          <div class="product-price">${formatPrice(product.price)}</div>
          <p class="product-description">${product.description.substring(0, 80)}...</p>
          <div class="product-category" style="font-size:0.8rem; color:#888;">${product.category}</div>
        </div>
      </div>
    `).join('');
    
    document.querySelectorAll('.product-card').forEach(card => {
      card.addEventListener('click', () => {
        window.location.href = `/product.html?id=${card.dataset.productId}`;
      });
    });
  } catch (error) {
    console.error('Error loading products:', error);
    productGrid.innerHTML = '<div class="error-message">Failed to load products</div>';
  }
}

function setupSearchAndFilter() {
  const searchBtn = document.getElementById('searchBtn');
  const searchInput = document.getElementById('searchInput');
  const categoryFilter = document.getElementById('categoryFilter');
  
  if (searchBtn && searchInput && categoryFilter) {
    const performSearch = () => {
      currentSearch = searchInput.value.trim();
      currentCategory = categoryFilter.value;
      loadProducts();
    };
    searchBtn.addEventListener('click', performSearch);
    searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') performSearch();
    });
    categoryFilter.addEventListener('change', performSearch);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadCategories();
  loadProducts();
  setupSearchAndFilter();
});
EOF

# frontend/js/product.js (unchanged)
cat > frontend/js/product.js << 'EOF'
let currentProduct = null;

async function loadProduct() {
  const urlParams = new URLSearchParams(window.location.search);
  const productId = urlParams.get('id');
  if (!productId) { window.location.href = '/'; return; }
  
  const productDetail = document.getElementById('productDetail');
  try {
    const product = await apiRequest(`/products/${productId}`);
    currentProduct = product;
    productDetail.innerHTML = `
      <img src="${product.imageUrl}" alt="${product.name}" class="product-detail-image">
      <div class="product-detail-info">
        <h1>${product.name}</h1>
        <p class="product-detail-price">${formatPrice(product.price)}</p>
        <p>${product.description}</p>
        <p><strong>Category:</strong> ${product.category}</p>
        <div class="quantity-selector">
          <label>Quantity:</label>
          <input type="number" id="quantity" min="1" value="1">
        </div>
        <button id="addToCartBtn" class="btn btn-primary">Add to Cart</button>
      </div>
    `;
    document.getElementById('addToCartBtn').addEventListener('click', addToCart);
  } catch (error) {
    console.error('Error loading product:', error);
    productDetail.innerHTML = '<div class="error-message">Failed to load product details</div>';
  }
}

async function addToCart() {
  if (!isLoggedIn()) {
    if (confirm('Please login to add items to cart. Go to login page?')) {
      window.location.href = '/login.html';
    }
    return;
  }
  const quantity = parseInt(document.getElementById('quantity').value);
  try {
    await apiRequest(`/cart/${currentProduct._id}`, {
      method: 'POST',
      body: JSON.stringify({ quantity })
    });
    alert('Product added to cart successfully!');
  } catch (error) {
    alert(error.message || 'Failed to add to cart');
  }
}

document.addEventListener('DOMContentLoaded', () => { loadProduct(); });
EOF

# frontend/js/cart.js (unchanged but keep)
cat > frontend/js/cart.js << 'EOF'
let cartData = null;

async function loadCart() {
  const cartContainer = document.getElementById('cartContainer');
  if (!isLoggedIn()) {
    cartContainer.innerHTML = `<div class="empty-cart"><p>Please login to view your cart</p><a href="/login.html" class="btn btn-primary">Login</a></div>`;
    return;
  }
  try {
    const cart = await apiRequest('/cart');
    cartData = cart;
    renderCart(cart);
  } catch (error) {
    console.error('Error loading cart:', error);
    cartContainer.innerHTML = '<div class="error-message">Failed to load cart</div>';
  }
}

function renderCart(cart) {
  const cartContainer = document.getElementById('cartContainer');
  if (!cart.items || cart.items.length === 0) {
    cartContainer.innerHTML = `<div class="empty-cart"><p>Your cart is empty</p><a href="/" class="btn btn-primary">Continue Shopping</a></div>`;
    return;
  }
  cartContainer.innerHTML = `
    <div class="cart-container">
      ${cart.items.map(item => `
        <div class="cart-item" data-product-id="${item.productId}">
          <img src="${item.imageUrl}" alt="${item.name}" class="cart-item-image">
          <div class="cart-item-details"><h3>${item.name}</h3><div class="cart-item-price">${formatPrice(item.price)}</div></div>
          <input type="number" class="cart-item-quantity" value="${item.quantity}" min="1" data-product-id="${item.productId}">
          <div class="cart-item-total">${formatPrice(item.totalPrice)}</div>
          <button class="btn btn-danger remove-item" data-product-id="${item.productId}">Remove</button>
        </div>
      `).join('')}
      <div class="cart-summary">
        <div class="cart-total">Total: ${formatPrice(cart.totalAmount)}</div>
        <a href="/checkout.html" class="btn btn-primary">Proceed to Checkout</a>
        <a href="/" class="btn btn-secondary">Continue Shopping</a>
      </div>
    </div>
  `;
  document.querySelectorAll('.cart-item-quantity').forEach(input => {
    input.addEventListener('change', async (e) => {
      const productId = e.target.dataset.productId;
      const newQuantity = parseInt(e.target.value);
      if (newQuantity > 0) await updateQuantity(productId, newQuantity);
      else { e.target.value = 1; await updateQuantity(productId, 1); }
    });
  });
  document.querySelectorAll('.remove-item').forEach(btn => {
    btn.addEventListener('click', async (e) => {
      await removeItem(btn.dataset.productId);
    });
  });
}

async function updateQuantity(productId, quantity) {
  try {
    await apiRequest(`/cart/${productId}`, { method: 'PUT', body: JSON.stringify({ quantity }) });
    await loadCart();
  } catch (error) { alert(error.message || 'Failed to update quantity'); await loadCart(); }
}

async function removeItem(productId) {
  try {
    await apiRequest(`/cart/${productId}`, { method: 'DELETE' });
    await loadCart();
  } catch (error) { alert(error.message || 'Failed to remove item'); }
}

document.addEventListener('DOMContentLoaded', () => { loadCart(); });
EOF

# frontend/js/checkout.js (unchanged)
cat > frontend/js/checkout.js << 'EOF'
async function loadOrderSummary() {
  if (!isLoggedIn()) { window.location.href = '/login.html'; return; }
  try {
    const cart = await apiRequest('/cart');
    if (!cart.items || cart.items.length === 0) {
      alert('Your cart is empty. Please add items before checkout.');
      window.location.href = '/';
      return;
    }
    const orderSummaryItems = document.getElementById('orderSummaryItems');
    orderSummaryItems.innerHTML = cart.items.map(item => `
      <div class="cart-item" style="grid-template-columns: 1fr auto auto; padding: 0.5rem 0;">
        <span>${item.name} x ${item.quantity}</span><span>${formatPrice(item.price)}</span><span>${formatPrice(item.totalPrice)}</span>
      </div>
    `).join('');
    document.getElementById('orderTotal').textContent = formatPrice(cart.totalAmount);
  } catch (error) { console.error('Error loading order summary:', error); alert('Failed to load order summary'); }
}

document.getElementById('checkoutForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const address = document.getElementById('address').value;
  const phone = document.getElementById('phone').value;
  if (!address || !phone) { alert('Please fill in all fields'); return; }
  try {
    const result = await apiRequest('/order', { method: 'POST', body: JSON.stringify({ address, phone }) });
    alert(`Order placed successfully! Order ID: ${result.orderId}`);
    window.location.href = '/';
  } catch (error) { alert(error.message || 'Failed to place order'); }
});

document.addEventListener('DOMContentLoaded', () => { loadOrderSummary(); });
EOF

# frontend/js/auth.js (unchanged)
cat > frontend/js/auth.js << 'EOF'
document.getElementById('registerForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const name = document.getElementById('name').value;
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  try {
    const response = await fetch(`${API_BASE}/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, email, password })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    setToken(data.token);
    setCurrentUser(data.user);
    showMessage('registerMessage', 'Registration successful! Redirecting...', false);
    setTimeout(() => { window.location.href = '/'; }, 1500);
  } catch (error) { showMessage('registerMessage', error.message, true); }
});

document.getElementById('loginForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  try {
    const response = await fetch(`${API_BASE}/login`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    setToken(data.token);
    setCurrentUser(data.user);
    showMessage('loginMessage', 'Login successful! Redirecting...', false);
    setTimeout(() => { window.location.href = '/'; }, 1500);
  } catch (error) { showMessage('loginMessage', error.message, true); }
});

window.logout = logout;
EOF

# NEW: frontend/js/orders.js
cat > frontend/js/orders.js << 'EOF'
async function loadOrders() {
  const ordersContainer = document.getElementById('ordersContainer');
  if (!isLoggedIn()) {
    ordersContainer.innerHTML = `<div class="empty-cart"><p>Please login to view your orders</p><a href="/login.html" class="btn btn-primary">Login</a></div>`;
    return;
  }
  try {
    const orders = await apiRequest('/orders');
    if (!orders.length) {
      ordersContainer.innerHTML = `<div class="empty-cart"><p>You haven't placed any orders yet</p><a href="/" class="btn btn-primary">Start Shopping</a></div>`;
      return;
    }
    ordersContainer.innerHTML = orders.map(order => `
      <div class="order-card">
        <div class="order-header">
          <span class="order-id">Order #${order._id.slice(-8)}</span>
          <span class="order-status status-${order.status}">${order.status.toUpperCase()}</span>
          <span>${new Date(order.createdAt).toLocaleDateString()}</span>
        </div>
        <div class="order-items">
          ${order.items.map(item => `<div class="order-item"><span>${item.name} x ${item.quantity}</span><span>${formatPrice(item.price * item.quantity)}</span></div>`).join('')}
        </div>
        <div class="order-total">Total: ${formatPrice(order.totalAmount)}</div>
        <div class="order-address"><small>Deliver to: ${order.address} | Phone: ${order.phone}</small></div>
      </div>
    `).join('');
  } catch (error) {
    console.error('Error loading orders:', error);
    ordersContainer.innerHTML = '<div class="error-message">Failed to load orders</div>';
  }
}

document.addEventListener('DOMContentLoaded', () => { loadOrders(); });
EOF

# NEW: frontend/js/profile.js
cat > frontend/js/profile.js << 'EOF'
async function loadProfile() {
  const profileContainer = document.getElementById('profileContainer');
  if (!isLoggedIn()) {
    profileContainer.innerHTML = `<div class="empty-cart"><p>Please login to view your profile</p><a href="/login.html" class="btn btn-primary">Login</a></div>`;
    return;
  }
  try {
    const user = await apiRequest('/me');
    profileContainer.innerHTML = `
      <div class="profile-info">
        <h2>Welcome, ${user.name}!</h2>
        <p><span class="profile-label">Email:</span> ${user.email}</p>
        <p><span class="profile-label">Member since:</span> ${new Date(user.createdAt).toLocaleDateString()}</p>
        <p><span class="profile-label">Orders placed:</span> ${user.orderCount || 0}</p>
        <div style="margin-top: 2rem;">
          <a href="/orders.html" class="btn btn-primary">View My Orders</a>
          <a href="/" class="btn btn-secondary">Continue Shopping</a>
        </div>
      </div>
    `;
  } catch (error) {
    console.error('Error loading profile:', error);
    profileContainer.innerHTML = '<div class="error-message">Failed to load profile</div>';
  }
}

document.addEventListener('DOMContentLoaded', () => { loadProfile(); });
EOF

echo "✅ Full-stack e-commerce application with additional features (orders, search, categories, profile) has been created successfully!"
echo ""
echo "🚀 To run the application:"
echo "1. Make sure MongoDB is running (command: mongod)"
echo "2. Navigate to backend folder: cd backend"
echo "3. Install dependencies: npm install"
echo "4. Start the server: npm start (or npm run dev for auto-reload)"
echo "5. Open your browser at: http://localhost:5000"
echo ""
echo "📦 New features added:"
echo "- Order History page (My Orders)"
echo "- User Profile page"
echo "- Product search by name"
echo "- Category filter dropdown"
echo "- Enhanced navbar with Profile & Orders links"
echo "- Order status (pending/confirmed/shipped/delivered/cancelled)"
echo "- Better responsive design"
echo ""
echo "🎯 This full application is ready for automation testing with rich interaction points."