
    function togglePasswordVisibility() {
    const input = document.getElementById('password-field');
    const icon = document.querySelector('.toggle-password');
    if (input && icon) {
    if (input.type === 'password') {
    input.type = 'text';
    icon.textContent = '🙈';
} else {
    input.type = 'password';
    icon.textContent = '👁️';
}
}
}

    document.addEventListener("DOMContentLoaded", function () {
    const form = document.querySelector("form");
    const checkbox = document.getElementById("terms-agree");

    if (form && checkbox) {
    form.addEventListener("submit", function (e) {
    if (!checkbox.checked) {
    alert("You must agree to the Terms and Policies to sign up.");
    e.preventDefault();
}
});
}
});
