async function loadAdminStats() {
  try {
    const stats = await apiRequest('/admin/stats');
    document.getElementById('adminStats').innerHTML = `
      <div class="stat-card">Total Products: ${stats.totalProducts}</div>
      <div class="stat-card">Total Orders: ${stats.totalOrders}</div>
      <div class="stat-card">Total Users: ${stats.totalUsers}</div>
      <div class="stat-card">Revenue: ${formatPrice(stats.totalRevenue)}</div>
    `;
    const orders = await apiRequest('/admin/orders');
    const ordersHtml = orders.map(order => `
      <div class="order-card">
        <div>Order #${order._id.slice(-8)} | User: ${order.user?.name || 'Unknown'} | Total: ${formatPrice(order.totalAmount)}</div>
        <div>Status: 
          <select class="order-status" data-id="${order._id}">
            <option ${order.status === 'pending' ? 'selected' : ''}>pending</option>
            <option ${order.status === 'confirmed' ? 'selected' : ''}>confirmed</option>
            <option ${order.status === 'shipped' ? 'selected' : ''}>shipped</option>
            <option ${order.status === 'delivered' ? 'selected' : ''}>delivered</option>
            <option ${order.status === 'cancelled' ? 'selected' : ''}>cancelled</option>
          </select>
        </div>
      </div>
    `).join('');
    document.getElementById('adminOrders').innerHTML = ordersHtml;
    document.querySelectorAll('.order-status').forEach(select => {
      select.addEventListener('change', async (e) => {
        const orderId = select.dataset.id;
        const newStatus = select.value;
        await apiRequest(`/admin/orders/${orderId}`, { method: 'PUT', body: JSON.stringify({ status: newStatus }) });
        alert('Order status updated');
      });
    });
  } catch (err) { console.error(err); }
}
document.getElementById('addProductForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const product = {
    name: document.getElementById('productName').value,
    description: document.getElementById('productDesc').value,
    price: parseFloat(document.getElementById('productPrice').value),
    imageUrl: document.getElementById('productImage').value,
    category: document.getElementById('productCategory').value,
    stock: parseInt(document.getElementById('productStock').value)
  };
  await apiRequest('/admin/products', { method: 'POST', body: JSON.stringify(product) });
  alert('Product added');
  location.reload();
});
document.addEventListener('DOMContentLoaded', loadAdminStats);
