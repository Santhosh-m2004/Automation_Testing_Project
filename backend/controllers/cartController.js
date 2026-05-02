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
