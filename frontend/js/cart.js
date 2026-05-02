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
