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
