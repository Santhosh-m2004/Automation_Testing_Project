let currentPage = 1;
let totalPages = 1;

function showMarketingContent() {
  document.getElementById('marketingContent').style.display = 'block';
  document.getElementById('productSection').style.display = 'none';
}

function showProductGrid() {
  document.getElementById('marketingContent').style.display = 'none';
  document.getElementById('productSection').style.display = 'block';
}

async function loadCategories() {
  try {
    const categories = await apiRequest('/categories');
    const select = document.getElementById('categoryFilter');
    if (select) {
      select.innerHTML = '<option value="all">All Categories</option>';
      categories.forEach(cat => {
        select.innerHTML += `<option value="${cat}">${cat}</option>`;
      });
    }
  } catch (error) {
    console.error('Error loading categories:', error);
  }
}

async function loadProducts() {
  const productGrid = document.getElementById('productGrid');
  if (!productGrid) return;
  
  productGrid.innerHTML = '<div class="loading">Loading products...</div>';
  
  const search = document.getElementById('searchInput')?.value || '';
  const category = document.getElementById('categoryFilter')?.value || 'all';
  
  try {
    const url = `/api/products?page=${currentPage}&limit=8&search=${encodeURIComponent(search)}&category=${encodeURIComponent(category)}`;
    const response = await fetch(url);
    const data = await response.json();
    
    let products = [];
    if (Array.isArray(data)) {
      products = data;
      totalPages = 1;
    } else if (data && Array.isArray(data.products)) {
      products = data.products;
      totalPages = data.totalPages || 1;
    } else {
      throw new Error('Unexpected API response format');
    }
    
    if (!products.length) {
      productGrid.innerHTML = '<div class="empty-cart">No products found</div>';
      renderPagination();
      return;
    }
    
    productGrid.innerHTML = products.map(product => `
      <div class="product-card" data-product-id="${product._id}">
        <img src="${product.imageUrl}" alt="${product.name}" class="product-image">
        <div class="product-info">
          <h3 class="product-name">${escapeHtml(product.name)}</h3>
          <div class="product-price">${formatPrice(product.price)}</div>
          <p class="product-description">${escapeHtml(product.description.substring(0, 80))}...</p>
          ${product.averageRating ? `<div>⭐ ${product.averageRating.toFixed(1)} (${product.reviewCount || 0} reviews)</div>` : ''}
        </div>
      </div>
    `).join('');
    
    document.querySelectorAll('.product-card').forEach(card => {
      card.addEventListener('click', () => {
        window.location.href = `/product.html?id=${card.dataset.productId}`;
      });
    });
    
    renderPagination();
  } catch (error) {
    console.error('Error loading products:', error);
    productGrid.innerHTML = '<div class="error-message">Failed to load products. Make sure backend is running.</div>';
  }
}

function renderPagination() {
  if (totalPages <= 1) return;
  
  let paginationDiv = document.getElementById('pagination');
  if (!paginationDiv) {
    paginationDiv = document.createElement('div');
    paginationDiv.id = 'pagination';
    paginationDiv.className = 'pagination';
    const section = document.getElementById('productSection');
    if (section) section.appendChild(paginationDiv);
  }
  
  let html = '';
  if (currentPage > 1) {
    html += `<button class="page-btn" data-page="${currentPage-1}">Prev</button>`;
  }
  for (let i = 1; i <= totalPages; i++) {
    html += `<button class="page-btn ${i === currentPage ? 'active' : ''}" data-page="${i}">${i}</button>`;
  }
  if (currentPage < totalPages) {
    html += `<button class="page-btn" data-page="${currentPage+1}">Next</button>`;
  }
  paginationDiv.innerHTML = html;
  
  document.querySelectorAll('.page-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      currentPage = parseInt(btn.dataset.page);
      loadProducts();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
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

function initHomepage() {
  if (isLoggedIn()) {
    showProductGrid();
    loadCategories();
    loadProducts();
  } else {
    showMarketingContent();
  }
}

// Set up search/filter only when product grid is active
function setupSearchAndFilter() {
  const searchBtn = document.getElementById('searchBtn');
  const searchInput = document.getElementById('searchInput');
  const categoryFilter = document.getElementById('categoryFilter');
  
  if (!searchBtn || !searchInput || !categoryFilter) return;
  
  const performSearch = () => {
    if (!isLoggedIn()) return;
    currentPage = 1;
    loadProducts();
  };
  
  searchBtn.addEventListener('click', performSearch);
  searchInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') performSearch();
  });
  categoryFilter.addEventListener('change', performSearch);
}

// Also update navbar to refresh homepage on login/logout
// Override logout to redirect to homepage after logout
const originalLogout = window.logout;
window.logout = function() {
  setToken(null);
  setCurrentUser(null);
  // Reload page to show marketing content
  window.location.href = '/';
};

document.addEventListener('DOMContentLoaded', () => {
  initHomepage();
  setupSearchAndFilter();
});

// Listen for login state changes (e.g., after login in other tabs)
window.addEventListener('storage', (e) => {
  if (e.key === 'token') {
    initHomepage();
  }
});
