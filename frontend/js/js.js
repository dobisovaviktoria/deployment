const API_URL = '/api/groceries';

async function loadGroceries() {
    const res = await fetch(API_URL);
    const items = await res.json();

    const tbody = document.getElementById('grocery-list');
    tbody.innerHTML = '';

    items.forEach(item => {
        const row = document.createElement('tr');

        row.innerHTML = `
        <td>${item.name}</td>
        <td>${item.quantity}</td>
        <td>${item.category}</td>
        <td><button onclick="deleteItem(${item.id})">Delete</button></td>
      `;

        tbody.appendChild(row);
    });
}

async function loadCategories() {
    const res = await fetch('/api/groceries/categories');
    const categories = await res.json();

    const categorySelect = document.getElementById('category');
    categorySelect.innerHTML = '<option value="" disabled selected>Select Category</option>';

    categories.forEach(cat => {
        const option = document.createElement('option');
        option.value = cat;
        option.textContent = cat;
        categorySelect.appendChild(option);
    });
}

async function addItem(e) {
    e.preventDefault();

    const name = document.getElementById('name').value;
    const quantity = document.getElementById('quantity').value;
    const category = document.getElementById('category').value;

    const item = { name, quantity, category };

    await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(item)
    });

    e.target.reset();
    await loadGroceries();
}

async function deleteItem(id) {
    await fetch(`${API_URL}/${id}`, {
        method: 'DELETE'
    });

    await loadGroceries();
}

document.getElementById('add-form').addEventListener('submit', addItem);

loadGroceries();
loadCategories();