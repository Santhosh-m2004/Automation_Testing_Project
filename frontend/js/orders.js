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
