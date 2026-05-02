document.getElementById('registerForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const name = document.getElementById('name').value;
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  try {
    const response = await fetch(`${API_BASE}/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, email, password })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    setToken(data.token);
    setCurrentUser(data.user);
    showMessage('registerMessage', 'Registration successful! Redirecting...', false);
    setTimeout(() => { window.location.href = '/'; }, 1500);
  } catch (error) { showMessage('registerMessage', error.message, true); }
});

document.getElementById('loginForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  try {
    const response = await fetch(`${API_BASE}/login`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    setToken(data.token);
    setCurrentUser(data.user);
    showMessage('loginMessage', 'Login successful! Redirecting...', false);
    setTimeout(() => { window.location.href = '/'; }, 1500);
  } catch (error) { showMessage('loginMessage', error.message, true); }
});

window.logout = logout;
