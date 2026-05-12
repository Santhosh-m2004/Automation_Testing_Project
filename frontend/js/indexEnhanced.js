let currentPage = 1;
let totalPages = 1;

async function loadProducts() {
  const productGrid = document.getElementById('productGrid');
  productGrid.innerHTML = '<div class="loading">Loading...</div>';
  const search = document.getElementById('searchInput')?.value || '';
  const category = document.getElementById('categoryFilter')?.value || 'all';
  try {
    const data = await apiRequest(`/products?page=${currentPage}&limit=8&search=${encodeURIComponent(search)}&category=${category}`);
    const products = data.products;
    totalPages = data.totalPages;
    if (!products.length) { productGrid.innerHTML = '<div class="empty-cart">No products</div>'; return; }
    productGrid.innerHTML = products.map(p => `
      <div class="product-card" data-id="${p._id}">
        <img src="${p.imageUrl}" class="product-image"><div class="product-info">
        <h3>${p.name}</h3><div class="product-price">${formatPrice(p.price)}</div>
        <div>⭐ ${p.averageRating ? p.averageRating.toFixed(1) : 'New'}</div>
        </div></div>
    `).join('');
    document.querySelectorAll('.product-card').forEach(card => {
      card.addEventListener('click', () => window.location.href = `/product.html?id=${card.dataset.id}`);
    });
    renderPagination();
  } catch (err) { console.error(err); }
}

function renderPagination() {
  let paginationDiv = document.getElementById('pagination');
  if (!paginationDiv) {
    paginationDiv = document.createElement('div');
    paginationDiv.id = 'pagination';
    document.querySelector('.container').appendChild(paginationDiv);
  }
  let html = '<div class="pagination">';
  if (currentPage > 1) html += `<button class="page-btn" data-page="${currentPage-1}">Prev</button>`;
  for (let i = 1; i <= totalPages; i++) {
    html += `<button class="page-btn ${i === currentPage ? 'active' : ''}" data-page="${i}">${i}</button>`;
  }
  if (currentPage < totalPages) html += `<button class="page-btn" data-page="${currentPage+1}">Next</button>`;
  html += '</div>';
  paginationDiv.innerHTML = html;
  document.querySelectorAll('.page-btn').forEach(btn => {
    btn.addEventListener('click', () => { currentPage = parseInt(btn.dataset.page); loadProducts(); });
  });
}

document.addEventListener('DOMContentLoaded', () => {
  loadProducts();
  document.getElementById('searchBtn')?.addEventListener('click', () => { currentPage = 1; loadProducts(); });
  document.getElementById('categoryFilter')?.addEventListener('change', () => { currentPage = 1; loadProducts(); });
});
