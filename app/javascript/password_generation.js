function generatePassword(length = 12) {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$!";
    let password = "";
    for (let i = 0; i < length; i++) {
        password += charset[Math.floor(Math.random() * charset.length)];
    }
    document.getElementById("suggestedPassword").value = password;
    updateStrength(password);
}

function openPasswordModal() {
    generatePassword();
    document.getElementById("passwordModal").style.display = "block";
}

function clickOutsideModal(e) {
    if (e.target.id === "passwordModal") {
        document.getElementById("passwordModal").style.display = "none";
    }
}

function copyPassword() {
    const pw = document.getElementById("suggestedPassword");
    pw.select();
    document.execCommand("copy");
}

function useSuggestedPassword() {
    const pw = document.getElementById("suggestedPassword").value;
    document.getElementById("user_password").value = pw;
    document.getElementById("user_password_confirmation").value = pw;
    updateStrength(pw);
    document.getElementById("passwordModal").style.display = "none";
}

function togglePassword(id) {
    const field = document.getElementById(id);
    field.type = field.type === "password" ? "text" : "password";
}

function updateStrength(password) {
    const strengthEl = document.getElementById("password-strength");
    let strength = 0;
    if (password.length >= 8) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[@#$!]/.test(password)) strength++;

    if (strength >= 4) {
        strengthEl.innerText = "Strength: Strong";
        strengthEl.style.color = "green";
    } else if (strength >= 2) {
        strengthEl.innerText = "Strength: Medium";
        strengthEl.style.color = "orange";
    } else {
        strengthEl.innerText = "Strength: Weak";
        strengthEl.style.color = "red";
    }
}
