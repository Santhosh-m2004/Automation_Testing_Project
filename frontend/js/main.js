// Global helper functions

const API_BASE = '/api';

function getToken() {
  return localStorage.getItem('token');
}

function setToken(token) {
  if (token) {
    localStorage.setItem('token', token);
  } else {
    localStorage.removeItem('token');
  }
}

function getCurrentUser() {
  const userStr = localStorage.getItem('user');
  if (userStr) {
    try {
      return JSON.parse(userStr);
    } catch (e) {
      return null;
    }
  }
  return null;
}

function setCurrentUser(user) {
  if (user) {
    localStorage.setItem('user', JSON.stringify(user));
  } else {
    localStorage.removeItem('user');
  }
}

function isLoggedIn() {
  return !!getToken();
}

function logout() {
  setToken(null);
  setCurrentUser(null);
  window.location.href = '/';
}

async function apiRequest(url, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  const response = await fetch(`${API_BASE}${url}`, {
    ...options,
    headers
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }
  return data;
}

function showMessage(elementId, message, isError = true) {
  const element = document.getElementById(elementId);
  if (element) {
    element.textContent = message;
    element.className = `message ${isError ? 'error-message' : 'success-message'}`;
    setTimeout(() => {
      element.textContent = '';
      element.className = 'message';
    }, 3000);
  }
}

function formatPrice(price) {
  return `$${price.toFixed(2)}`;
}

function updateNavbar() {
  const authLinks = document.getElementById('authLinks');
  if (!authLinks) return;
  
  if (isLoggedIn()) {
    const user = getCurrentUser();
    authLinks.innerHTML = `
      <a href="/profile.html" class="nav-link"><i class="fas fa-user"></i> Profile</a>
      <a href="/orders.html" class="nav-link"><i class="fas fa-box"></i> Orders</a>
      <span class="nav-link">Hello, ${user ? user.name : 'User'}</span>
      <a href="#" onclick="logout(); return false;" class="nav-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
    `;
  } else {
    authLinks.innerHTML = `
      <a href="/login.html" class="nav-link"><i class="fas fa-sign-in-alt"></i> Login</a>
    `;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  updateNavbar();
});
