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
