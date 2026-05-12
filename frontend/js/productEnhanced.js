// Enhanced product.js with reviews and wishlist button
let currentProductId = null;

async function loadProduct() {
  const urlParams = new URLSearchParams(window.location.search);
  const productId = urlParams.get('id');
  if (!productId) { window.location.href = '/'; return; }
  currentProductId = productId;
  try {
    const product = await apiRequest(`/products/${productId}`);
    document.getElementById('productDetail').innerHTML = `
      <img src="${product.imageUrl}" class="product-detail-image">
      <div class="product-detail-info">
        <h1>${product.name}</h1>
        <p class="product-detail-price">${formatPrice(product.price)}</p>
        <p>${product.description}</p>
        <p>⭐ ${product.averageRating ? product.averageRating.toFixed(1) : 'No ratings'} (${product.reviewCount || 0} reviews)</p>
        <div class="quantity-selector"><label>Quantity:</label><input type="number" id="quantity" min="1" value="1"></div>
        <button id="addToCartBtn" class="btn btn-primary">Add to Cart</button>
        <button id="wishlistBtn" class="btn btn-secondary">❤️ Add to Wishlist</button>
      </div>
    `;
    document.getElementById('addToCartBtn').addEventListener('click', addToCart);
    document.getElementById('wishlistBtn').addEventListener('click', addToWishlist);
    loadReviews(productId);
    if (isLoggedIn()) document.getElementById('addReviewForm').style.display = 'block';
  } catch (err) { console.error(err); }
}

async function addToWishlist() {
  if (!isLoggedIn()) { alert('Please login'); return; }
  await apiRequest(`/wishlist/${currentProductId}`, { method: 'POST' });
  alert('Added to wishlist');
}

async function loadReviews(productId) {
  const reviews = await apiRequest(`/products/${productId}/reviews`);
  const container = document.getElementById('reviewsList');
  if (!reviews.length) { container.innerHTML = '<p>No reviews yet.</p>'; return; }
  container.innerHTML = reviews.map(r => `
    <div class="review"><strong>${r.userName}</strong> ⭐ ${r.rating}/5<br>${r.comment}<br><small>${new Date(r.createdAt).toLocaleDateString()}</small></div>
  `).join('');
}

document.getElementById('submitReviewBtn')?.addEventListener('click', async () => {
  const rating = document.getElementById('ratingSelect').value;
  const comment = document.getElementById('reviewComment').value;
  if (!comment) { alert('Please write a review'); return; }
  await apiRequest(`/products/${currentProductId}/reviews`, {
    method: 'POST', body: JSON.stringify({ rating: parseInt(rating), comment })
  });
  alert('Review submitted');
  loadReviews(currentProductId);
});

document.addEventListener('DOMContentLoaded', loadProduct);
