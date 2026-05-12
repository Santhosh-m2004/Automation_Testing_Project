async function loadWishlist() {
  const container = document.getElementById('wishlistContainer');
  if (!container) return;

  // Check if user is logged in
  if (!isLoggedIn()) {
    container.innerHTML = '<div class="empty-cart">Please login to view your wishlist</div>';
    return;
  }

  container.innerHTML = '<div class="loading">Loading wishlist...</div>';
  
  try {
    const items = await apiRequest('/wishlist');
    if (!items.length) {
      container.innerHTML = '<div class="empty-cart">Your wishlist is empty</div>';
      return;
    }
    
    container.innerHTML = items.map(item => `
      <div class="product-card" data-product-id="${item.productId}">
        <img src="${item.imageUrl}" class="product-image" alt="${item.name}">
        <div class="product-info">
          <h3>${escapeHtml(item.name)}</h3>
          <div class="product-price">${formatPrice(item.price)}</div>
          <button class="btn btn-primary add-to-cart-wishlist" data-id="${item.productId}">Add to Cart</button>
          <button class="btn btn-danger remove-wishlist" data-id="${item.productId}">Remove</button>
        </div>
      </div>
    `).join('');
    
    // Add event listeners
    document.querySelectorAll('.add-to-cart-wishlist').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        e.stopPropagation();
        const pid = btn.dataset.id;
        await apiRequest(`/cart/${pid}`, { method: 'POST', body: JSON.stringify({ quantity: 1 }) });
        alert('Added to cart');
      });
    });
    
    document.querySelectorAll('.remove-wishlist').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        e.stopPropagation();
        const pid = btn.dataset.id;
        await apiRequest(`/wishlist/${pid}`, { method: 'DELETE' });
        loadWishlist(); // refresh after removal
      });
    });
  } catch (error) {
    console.error('Wishlist error:', error);
    if (error.message.includes('401') || error.message.includes('token')) {
      container.innerHTML = '<div class="error-message">Please login to view wishlist</div>';
    } else {
      container.innerHTML = '<div class="error-message">Failed to load wishlist. Make sure backend is running.</div>';
    }
  }
}

function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/[&<>]/g, function(m) {
    if (m === '&') return '&amp;';
    if (m === '<') return '&lt;';
    if (m === '>') return '&gt;';
    return m;
  });
}

document.addEventListener('DOMContentLoaded', loadWishlist);
