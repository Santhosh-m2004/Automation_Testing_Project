// Authentication functions for login and register pages

// Helper to show messages on auth pages
function showAuthMessage(elementId, message, isError = true) {
  const element = document.getElementById(elementId);
  if (element) {
    element.textContent = message;
    element.className = `message ${isError ? 'error-message' : 'success-message'}`;
    setTimeout(() => {
      element.textContent = '';
      element.className = 'message';
    }, 5000);
  }
}

// Registration handler
document.addEventListener('DOMContentLoaded', function() {
  const registerForm = document.getElementById('registerForm');
  if (registerForm) {
    registerForm.addEventListener('submit', async function(e) {
      e.preventDefault();
      const name = document.getElementById('name').value.trim();
      const email = document.getElementById('email').value.trim();
      const password = document.getElementById('password').value;

      if (!name || !email || !password) {
        showAuthMessage('registerMessage', 'Please fill in all fields', true);
        return;
      }
      if (password.length < 6) {
        showAuthMessage('registerMessage', 'Password must be at least 6 characters', true);
        return;
      }

      try {
        const response = await fetch('/api/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, email, password })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.message || 'Registration failed');

        // Save token and user data
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        showAuthMessage('registerMessage', 'Registration successful! Redirecting...', false);
        setTimeout(() => {
          window.location.href = '/';
        }, 1500);
      } catch (error) {
        showAuthMessage('registerMessage', error.message, true);
      }
    });
  }

  // Login handler
  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', async function(e) {
      e.preventDefault();
      const email = document.getElementById('email').value.trim();
      const password = document.getElementById('password').value;

      if (!email || !password) {
        showAuthMessage('loginMessage', 'Please fill in all fields', true);
        return;
      }

      try {
        const response = await fetch('/api/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.message || 'Login failed');

        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        showAuthMessage('loginMessage', 'Login successful! Redirecting...', false);
        setTimeout(() => {
          window.location.href = '/';
        }, 1500);
      } catch (error) {
        showAuthMessage('loginMessage', error.message, true);
      }
    });
  }
});
