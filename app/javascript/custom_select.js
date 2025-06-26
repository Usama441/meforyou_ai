document.addEventListener('DOMContentLoaded', function () {
    const dropdown = document.getElementById('customDropdown');
    const selected = dropdown.querySelector('.selected');
    const options = dropdown.querySelector('.options');
    const input = document.getElementById('relationshipInput');

    selected.addEventListener('click', function (e) {
        options.style.display = options.style.display === 'block' ? 'none' : 'block';
    });

    options.addEventListener('click', function (e) {
        if (e.target.dataset.value) {
            const value = e.target.dataset.value;
            selected.textContent = e.target.textContent;
            input.value = value;
            options.style.display = 'none';
        }
    });

    document.addEventListener('click', function (e) {
        if (!dropdown.contains(e.target)) {
            options.style.display = 'none';
        }
    });
});
