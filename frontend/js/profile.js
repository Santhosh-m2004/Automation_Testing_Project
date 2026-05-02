async function loadProfile() {
  const profileContainer = document.getElementById('profileContainer');
  if (!isLoggedIn()) {
    profileContainer.innerHTML = `<div class="empty-cart"><p>Please login to view your profile</p><a href="/login.html" class="btn btn-primary">Login</a></div>`;
    return;
  }
  try {
    const user = await apiRequest('/me');
    profileContainer.innerHTML = `
      <div class="profile-info">
        <h2>Welcome, ${user.name}!</h2>
        <p><span class="profile-label">Email:</span> ${user.email}</p>
        <p><span class="profile-label">Member since:</span> ${new Date(user.createdAt).toLocaleDateString()}</p>
        <p><span class="profile-label">Orders placed:</span> ${user.orderCount || 0}</p>
        <div style="margin-top: 2rem;">
          <a href="/orders.html" class="btn btn-primary">View My Orders</a>
          <a href="/" class="btn btn-secondary">Continue Shopping</a>
        </div>
      </div>
    `;
  } catch (error) {
    console.error('Error loading profile:', error);
    profileContainer.innerHTML = '<div class="error-message">Failed to load profile</div>';
  }
}

document.addEventListener('DOMContentLoaded', () => { loadProfile(); });
