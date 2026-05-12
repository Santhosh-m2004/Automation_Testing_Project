let currentProduct = null;
let currentProductId = null;

async function loadProduct() {
  const urlParams = new URLSearchParams(window.location.search);
  const productId = urlParams.get('id');
  if (!productId) {
    window.location.href = '/';
    return;
  }
  currentProductId = productId;
  
  const productDetail = document.getElementById('productDetail');
  if (!productDetail) return;
  
  productDetail.innerHTML = '<div class="loading">Loading product details...</div>';
  
  try {
    const product = await apiRequest(`/products/${productId}`);
    currentProduct = product;
    
    productDetail.innerHTML = `
      <img src="${product.imageUrl}" alt="${product.name}" class="product-detail-image">
      <div class="product-detail-info">
        <h1>${escapeHtml(product.name)}</h1>
        <p class="product-detail-price">${formatPrice(product.price)}</p>
        <p>${escapeHtml(product.description)}</p>
        <p><strong>Category:</strong> ${escapeHtml(product.category)}</p>
        ${product.averageRating ? `<p>⭐ ${product.averageRating.toFixed(1)} (${product.reviewCount || 0} reviews)</p>` : ''}
        <div class="quantity-selector">
          <label>Quantity:</label>
          <input type="number" id="quantity" min="1" value="1">
        </div>
        <button id="addToCartBtn" class="btn btn-primary">Add to Cart</button>
        <button id="wishlistBtn" class="btn btn-secondary">❤️ Add to Wishlist</button>
      </div>
    `;
    
    document.getElementById('addToCartBtn').addEventListener('click', addToCart);
    const wishlistBtn = document.getElementById('wishlistBtn');
    if (wishlistBtn) wishlistBtn.addEventListener('click', addToWishlist);
    
    loadReviews(productId);
    if (isLoggedIn()) {
      const reviewForm = document.getElementById('addReviewForm');
      if (reviewForm) reviewForm.style.display = 'block';
    }
  } catch (error) {
    console.error('Error loading product:', error);
    productDetail.innerHTML = '<div class="error-message">Failed to load product details. Make sure backend is running.</div>';
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
    await apiRequest(`/cart/${currentProductId}`, {
      method: 'POST',
      body: JSON.stringify({ quantity })
    });
    alert('Product added to cart successfully!');
  } catch (error) {
    alert(error.message || 'Failed to add to cart');
  }
}

async function addToWishlist() {
  if (!isLoggedIn()) {
    alert('Please login to add to wishlist');
    return;
  }
  try {
    await apiRequest(`/wishlist/${currentProductId}`, { method: 'POST' });
    alert('Added to wishlist!');
  } catch (error) {
    alert(error.message || 'Failed to add to wishlist');
  }
}

async function loadReviews(productId) {
  const reviewsList = document.getElementById('reviewsList');
  if (!reviewsList) return;
  
  try {
    const reviews = await apiRequest(`/products/${productId}/reviews`);
    if (!reviews.length) {
      reviewsList.innerHTML = '<p>No reviews yet. Be the first to review!</p>';
      return;
    }
    reviewsList.innerHTML = reviews.map(r => `
      <div class="review">
        <strong>${escapeHtml(r.userName)}</strong> ⭐ ${r.rating}/5<br>
        ${escapeHtml(r.comment)}<br>
        <small>${new Date(r.createdAt).toLocaleDateString()}</small>
      </div>
    `).join('');
  } catch (error) {
    console.error('Failed to load reviews', error);
    reviewsList.innerHTML = '<p>Unable to load reviews.</p>';
  }
}

document.getElementById('submitReviewBtn')?.addEventListener('click', async () => {
  if (!isLoggedIn()) {
    alert('Please login to submit a review');
    window.location.href = '/login.html';
    return;
  }
  const ratingSelect = document.getElementById('ratingSelect');
  const rating = ratingSelect ? parseInt(ratingSelect.value) : 5;
  const comment = document.getElementById('reviewComment')?.value.trim();
  if (!comment) {
    alert('Please write a review comment');
    return;
  }
  try {
    const result = await apiRequest(`/products/${currentProductId}/reviews`, {
      method: 'POST',
      body: JSON.stringify({ rating, comment })
    });
    alert(result.message || 'Review submitted successfully!');
    document.getElementById('reviewComment').value = '';
    await loadReviews(currentProductId);
  } catch (error) {
    console.error('Review submission error:', error);
    alert(error.message || 'Failed to submit review. Please try again.');
  }
});

function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/[&<>]/g, function(m) {
    if (m === '&') return '&amp;';
    if (m === '<') return '&lt;';
    if (m === '>') return '&gt;';
    return m;
  });
}

document.addEventListener('DOMContentLoaded', () => {
  loadProduct();
});
