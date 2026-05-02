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
