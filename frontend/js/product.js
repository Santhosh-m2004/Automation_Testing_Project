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
