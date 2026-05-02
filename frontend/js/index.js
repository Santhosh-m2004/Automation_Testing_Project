let currentSearch = '';
let currentCategory = 'all';

async function loadCategories() {
  try {
    const categories = await apiRequest('/categories');
    const select = document.getElementById('categoryFilter');
    if (select) {
      const optionAll = select.querySelector('option[value="all"]');
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
  productGrid.innerHTML = '<div class="loading">Loading products...</div>';
  
  try {
    let url = '/products?';
    if (currentSearch) url += `search=${encodeURIComponent(currentSearch)}&`;
    if (currentCategory && currentCategory !== 'all') url += `category=${encodeURIComponent(currentCategory)}&`;
    
    const products = await apiRequest(url);
    
    if (products.length === 0) {
      productGrid.innerHTML = '<div class="empty-cart">No products found</div>';
      return;
    }
    
    productGrid.innerHTML = products.map(product => `
      <div class="product-card" data-product-id="${product._id}">
        <img src="${product.imageUrl}" alt="${product.name}" class="product-image">
        <div class="product-info">
          <h3 class="product-name">${product.name}</h3>
          <div class="product-price">${formatPrice(product.price)}</div>
          <p class="product-description">${product.description.substring(0, 80)}...</p>
          <div class="product-category" style="font-size:0.8rem; color:#888;">${product.category}</div>
        </div>
      </div>
    `).join('');
    
    document.querySelectorAll('.product-card').forEach(card => {
      card.addEventListener('click', () => {
        window.location.href = `/product.html?id=${card.dataset.productId}`;
      });
    });
  } catch (error) {
    console.error('Error loading products:', error);
    productGrid.innerHTML = '<div class="error-message">Failed to load products</div>';
  }
}

function setupSearchAndFilter() {
  const searchBtn = document.getElementById('searchBtn');
  const searchInput = document.getElementById('searchInput');
  const categoryFilter = document.getElementById('categoryFilter');
  
  if (searchBtn && searchInput && categoryFilter) {
    const performSearch = () => {
      currentSearch = searchInput.value.trim();
      currentCategory = categoryFilter.value;
      loadProducts();
    };
    searchBtn.addEventListener('click', performSearch);
    searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') performSearch();
    });
    categoryFilter.addEventListener('change', performSearch);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadCategories();
  loadProducts();
  setupSearchAndFilter();
});
