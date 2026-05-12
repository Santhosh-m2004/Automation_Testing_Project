const API_BASE = '/api';
function getToken() { return localStorage.getItem('token'); }
function setToken(token) { token ? localStorage.setItem('token', token) : localStorage.removeItem('token'); }
function getCurrentUser() {
  const userStr = localStorage.getItem('user');
  if (userStr) try { return JSON.parse(userStr); } catch(e) { return null; }
  return null;
}
function setCurrentUser(user) { user ? localStorage.setItem('user', JSON.stringify(user)) : localStorage.removeItem('user'); }
function isLoggedIn() { return !!getToken(); }
function formatPrice(price) { return `$${parseFloat(price).toFixed(2)}`; }
async function apiRequest(url, options = {}) {
  const token = getToken();
  const headers = { 'Content-Type': 'application/json', ...options.headers };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  const response = await fetch(`${API_BASE}${url}`, { ...options, headers });
  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    const data = await response.json();
    if (!response.ok) throw new Error(data.message || `Error ${response.status}`);
    return data;
  } else {
    const text = await response.text();
    if (!response.ok) throw new Error(text || `Error ${response.status}`);
    return text;
  }
}
function logout() {
  setToken(null);
  setCurrentUser(null);
  window.location.href = '/';
}
function updateSidebar() {
  const linksContainer = document.getElementById('authSidebarLinks');
  const footer = document.getElementById('authSidebarFooter');
  if (!linksContainer) return;
  if (isLoggedIn()) {
    const user = getCurrentUser();
    linksContainer.innerHTML = `
      <a href="/wishlist.html" class="nav-link"><i class="fas fa-heart"></i> <span>Wishlist</span></a>
      <a href="/profile.html" class="nav-link"><i class="fas fa-user"></i> <span>Profile</span></a>
      <a href="/orders.html" class="nav-link"><i class="fas fa-box"></i> <span>Orders</span></a>
    `;
    footer.innerHTML = `
      <div class="user-info">Hello, ${user ? user.name : 'User'}</div>
      <button onclick="logout()" class="btn btn-secondary" style="width:100%; margin-top:0.5rem;"><i class="fas fa-sign-out-alt"></i> Logout</button>
    `;
    if (user && user.email === 'admin@example.com') {
      const adminLink = document.createElement('a');
      adminLink.href = '/admin.html';
      adminLink.className = 'nav-link';
      adminLink.innerHTML = '<i class="fas fa-tachometer-alt"></i> <span>Admin</span>';
      linksContainer.insertBefore(adminLink, linksContainer.firstChild);
    }
  } else {
    linksContainer.innerHTML = '';
    footer.innerHTML = `
      <a href="/login.html" class="btn btn-primary" style="display:block; margin-bottom:0.5rem;">Login</a>
      <a href="/register.html" class="btn btn-secondary" style="display:block;">Register</a>
    `;
  }
}
function initSidebarToggle() {
  const sidebar = document.getElementById('sidebar');
  const toggleBtn = document.getElementById('sidebarToggle');
  if (toggleBtn && sidebar) {
    toggleBtn.addEventListener('click', () => sidebar.classList.toggle('open'));
    document.addEventListener('click', (e) => {
      if (window.innerWidth <= 768 && sidebar.classList.contains('open') && !sidebar.contains(e.target) && e.target !== toggleBtn) {
        sidebar.classList.remove('open');
      }
    });
  }
}
document.addEventListener('DOMContentLoaded', () => {
  updateSidebar();
  initSidebarToggle();
});
window.logout = logout;
window.apiRequest = apiRequest;
window.formatPrice = formatPrice;
window.isLoggedIn = isLoggedIn;
