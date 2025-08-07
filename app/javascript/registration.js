// Country codes and registration methods functionality
document.addEventListener("DOMContentLoaded", () => {
    // Full list of countries with flags and dial codes, sorted by country name
    const countries = [
        { name: "Afghanistan", dial: "+93", flag: "🇦🇫" },
        { name: "Albania", dial: "+355", flag: "🇦🇱" },
        { name: "Algeria", dial: "+213", flag: "🇩🇿" },
        { name: "Andorra", dial: "+376", flag: "🇦🇩" },
        { name: "Angola", dial: "+244", flag: "🇦🇴" },
        { name: "Antigua and Barbuda", dial: "+1‑268", flag: "🇦🇬" },
        { name: "Argentina", dial: "+54", flag: "🇦🇷" },
        { name: "Armenia", dial: "+374", flag: "🇦🇲" },
        { name: "Australia", dial: "+61", flag: "🇦🇺" },
        { name: "Austria", dial: "+43", flag: "🇦🇹" },
        { name: "Azerbaijan", dial: "+994", flag: "🇦🇿" },
        { name: "Bahamas", dial: "+1‑242", flag: "🇧🇸" },
        { name: "Bahrain", dial: "+973", flag: "🇧🇭" },
        { name: "Bangladesh", dial: "+880", flag: "🇧🇩" },
        { name: "Barbados", dial: "+1‑246", flag: "🇧🇧" },
        { name: "Belarus", dial: "+375", flag: "🇧🇾" },
        { name: "Belgium", dial: "+32", flag: "🇧🇪" },
        { name: "Belize", dial: "+501", flag: "🇧🇿" },
        { name: "Benin", dial: "+229", flag: "🇧🇯" },
        { name: "Bhutan", dial: "+975", flag: "🇧🇹" },
        { name: "Bolivia", dial: "+591", flag: "🇧🇴" },
        { name: "Bosnia and Herzegovina", dial: "+387", flag: "🇧🇦" },
        { name: "Botswana", dial: "+267", flag: "🇧🇼" },
        { name: "Brazil", dial: "+55", flag: "🇧🇷" },
        { name: "Brunei", dial: "+673", flag: "🇧🇳" },
        { name: "Bulgaria", dial: "+359", flag: "🇧🇬" },
        { name: "Burkina Faso", dial: "+226", flag: "🇧🇫" },
        { name: "Burundi", dial: "+257", flag: "🇧🇮" },
        { name: "Cambodia", dial: "+855", flag: "🇰🇭" },
        { name: "Cameroon", dial: "+237", flag: "🇨🇲" },
        { name: "Canada", dial: "+1", flag: "🇨🇦" },
        { name: "Cape Verde", dial: "+238", flag: "🇨🇻" },
        { name: "Central African Republic", dial: "+236", flag: "🇨🇫" },
        { name: "Chad", dial: "+235", flag: "🇹🇩" },
        { name: "Chile", dial: "+56", flag: "🇨🇱" },
        { name: "China", dial: "+86", flag: "🇨🇳" },
        { name: "Colombia", dial: "+57", flag: "🇨🇴" },
        { name: "Comoros", dial: "+269", flag: "🇰🇲" },
        { name: "Congo (Brazzaville)", dial: "+242", flag: "🇨🇬" },
        { name: "Congo (Kinshasa)", dial: "+243", flag: "🇨🇩" },
        { name: "Costa Rica", dial: "+506", flag: "🇨🇷" },
        { name: "Croatia", dial: "+385", flag: "🇭🇷" },
        { name: "Cuba", dial: "+53", flag: "🇨🇺" },
        { name: "Cyprus", dial: "+357", flag: "🇨🇾" },
        { name: "Czech Republic", dial: "+420", flag: "🇨🇿" },
        { name: "Denmark", dial: "+45", flag: "🇩🇰" },
        { name: "Djibouti", dial: "+253", flag: "🇩🇯" },
        { name: "Dominica", dial: "+1‑767", flag: "🇩🇲" },
        { name: "Dominican Republic", dial: "+1‑809", flag: "🇩🇴" },
        { name: "Ecuador", dial: "+593", flag: "🇪🇨" },
        { name: "Egypt", dial: "+20", flag: "🇪🇬" },
        { name: "El Salvador", dial: "+503", flag: "🇸🇻" },
        { name: "Equatorial Guinea", dial: "+240", flag: "🇬🇶" },
        { name: "Eritrea", dial: "+291", flag: "🇪🇷" },
        { name: "Estonia", dial: "+372", flag: "🇪🇪" },
        { name: "Eswatini", dial: "+268", flag: "🇸🇿" },
        { name: "Ethiopia", dial: "+251", flag: "🇪🇹" },
        { name: "Fiji", dial: "+679", flag: "🇫🇯" },
        { name: "Finland", dial: "+358", flag: "🇫🇮" },
        { name: "France", dial: "+33", flag: "🇫🇷" },
        { name: "Gabon", dial: "+241", flag: "🇬🇦" },
        { name: "Gambia", dial: "+220", flag: "🇬🇲" },
        { name: "Georgia", dial: "+995", flag: "🇬🇪" },
        { name: "Germany", dial: "+49", flag: "🇩🇪" },
        { name: "Ghana", dial: "+233", flag: "🇬🇭" },
        { name: "Greece", dial: "+30", flag: "🇬🇷" },
        { name: "Grenada", dial: "+1‑473", flag: "🇬🇩" },
        { name: "Guatemala", dial: "+502", flag: "🇬🇹" },
        { name: "Guinea", dial: "+224", flag: "🇬🇳" },
        { name: "Guinea‑Bissau", dial: "+245", flag: "🇬🇼" },
        { name: "Guyana", dial: "+592", flag: "🇬🇾" },
        { name: "Haiti", dial: "+509", flag: "🇭🇹" },
        { name: "Honduras", dial: "+504", flag: "🇭🇳" },
        { name: "Hungary", dial: "+36", flag: "🇭🇺" },
        { name: "Iceland", dial: "+354", flag: "🇮🇸" },
        { name: "India", dial: "+91", flag: "🇮🇳" },
        { name: "Indonesia", dial: "+62", flag: "🇮🇩" },
        { name: "Iran", dial: "+98", flag: "🇮🇷" },
        { name: "Iraq", dial: "+964", flag: "🇮🇶" },
        { name: "Ireland", dial: "+353", flag: "🇮🇪" },
        { name: "Israel", dial: "+972", flag: "🇮🇱" },
        { name: "Italy", dial: "+39", flag: "🇮🇹" },
        { name: "Ivory Coast", dial: "+225", flag: "🇨🇮" },
        { name: "Jamaica", dial: "+1‑876", flag: "🇯🇲" },
        { name: "Japan", dial: "+81", flag: "🇯🇵" },
        { name: "Jordan", dial: "+962", flag: "🇯🇴" },
        { name: "Kazakhstan", dial: "+7", flag: "🇰🇿" },
        { name: "Kenya", dial: "+254", flag: "🇰🇪" },
        { name: "Kiribati", dial: "+686", flag: "🇰🇮" },
        { name: "Kuwait", dial: "+965", flag: "🇰🇼" },
        { name: "Kyrgyzstan", dial: "+996", flag: "🇰🇬" },
        { name: "Laos", dial: "+856", flag: "🇱🇦" },
        { name: "Latvia", dial: "+371", flag: "🇱🇻" },
        { name: "Lebanon", dial: "+961", flag: "🇱🇧" },
        { name: "Lesotho", dial: "+266", flag: "🇱🇸" },
        { name: "Liberia", dial: "+231", flag: "🇱🇷" },
        { name: "Libya", dial: "+218", flag: "🇱🇾" },
        { name: "Liechtenstein", dial: "+423", flag: "🇱🇮" },
        { name: "Lithuania", dial: "+370", flag: "🇱🇹" },
        { name: "Luxembourg", dial: "+352", flag: "🇱🇺" },
        { name: "Madagascar", dial: "+261", flag: "🇲🇬" },
        { name: "Malawi", dial: "+265", flag: "🇲🇼" },
        { name: "Malaysia", dial: "+60", flag: "🇲🇾" },
        { name: "Maldives", dial: "+960", flag: "🇲🇻" },
        {name: "Mali", dial: "+223", flag: "🇲🇱 "},
        {name: "Malta", dial: "+356", flag: "🇲🇹"},
        {name: "Marshall Islands", dial: "+692", flag: "🇲🇭"},
        {name: "Mauritania", dial: "+222", flag: "🇲🇷"},
        {name: "Mauritius", dial: "+230", flag: "🇲🇺"},
        {name: "Mexico", dial: "+52", flag: "🇲🇽"},
        {name: "Micronesia", dial: "+691", flag: "🇫🇲"},
        {name: "Moldova", dial: "+373", flag: "🇲🇩"},
        {name: "Monaco", dial: "+377", flag: "🇲🇨"},
        {name: "Mongolia", dial: "+976", flag: "🇲🇳"},
        {name: "Montenegro", dial: "+382", flag: "🇲🇪"},
        {name: "Morocco", dial: "+212", flag: "🇲🇦"},
        {name: "Mozambique", dial: "+258", flag: "🇲🇿"},
        {name: "Myanmar", dial: "+95", flag: "🇲🇲"},
        {name: "Namibia", dial: "+264", flag: "🇳🇦"},
        {name: "Nauru", dial: "+674", flag: "🇳🇷"},
        {name: "Nepal", dial: "+977", flag: "🇳🇵"},
        {name: "Netherlands", dial: "+31", flag: "🇳🇱"},
        {name: "New Zealand", dial: "+64", flag: "🇳🇿"},
        {name: "Nicaragua", dial: "+505", flag: "🇳🇮"},
        {name: "Niger", dial: "+227", flag: "🇳🇪"},
        {name: "Nigeria", dial: "+234", flag: "🇳🇬"},
        {name: "North Korea", dial: "+850", flag: "🇰🇵"},
        {name: "North Macedonia", dial: "+389", flag: "🇲🇰"},
        {name: "Norway", dial: "+47", flag: "🇳🇴"},
        {name: "Oman", dial: "+968", flag: "🇴🇲"},
        {name: "Pakistan", dial: "+92", flag: "🇵🇰"},
        {name: "Palau", dial: "+680", flag: "🇵🇼"},
        {name: "Palestine", dial: "+970", flag: "🇵🇸"},
        {name: "Panama", dial: "+507", flag: "🇵🇦"},
        {name: "Papua New Guinea ", dial: "+675", flag: "🇵🇬"},
        {name: "Paraguay", dial: "+595", flag: "🇵🇾"},
        {name: "Peru", dial: "+51", flag: "🇵🇪"},
        {name: "Philippines", dial: "+63", flag: "🇵🇭"},
        {name: "Poland", dial: "+48", flag: "🇵🇱"},
        {name: "Portugal", dial: "+351", flag: "🇵🇹"},
        {name: "Qatar", dial: "+974", flag: "🇶🇦"},
        {name: "Romania", dial: "+40", flag: "🇷🇴"},
        {name: "Russia", dial: "+7", flag: "🇷🇺"},
        {name: "Rwanda", dial: "+250", flag: "🇷🇼"},
        {name: "Saint Kitts and Nevis", dial: "+1-869", flag: "🇰🇳"},
        {name: "Saint Lucia", dial: "+1-758", flag: "🇱🇨"},
        {name: "Saint Vincent and the Grenadines", dial: "+1-784", flag: "🇻🇨"},
        {name: "Samoa", dial: "+685", flag: "🇼🇸"},
        {name: "San Marino", dial: "+378", flag: "🇸🇲"},
        {name: "Sao Tome and Principe", dial: "+239", flag: "🇸🇹"},
        {name: "Saudi Arabia", dial: "+966", flag: "🇸🇦"},
        {name: "Senegal", dial: "+221", flag: "🇸🇳"},
        {name: "Serbia", dial: "+381", flag: "🇷🇸"},
        {name: "Seychelles", dial: "+248", flag: "🇸🇨"},
        {name: "Sierra Leone", dial: "+232", flag: "🇸🇱"},
        {name: "Singapore", dial: "+65", flag: "🇸🇬"},
        {name: "Slovakia", dial: "+421", flag: "🇸🇰"},
        {name: "Slovenia", dial: "+386", flag: "🇸🇮"},
        {name: "Solomon Islands", dial: "+677", flag: "🇸🇧"},
        {name: "Somalia", dial: "+252", flag: "🇸🇴"},
        {name: "South Africa", dial: "+27", flag: "🇿🇦"},
        {name: "South Korea", dial: "+82", flag: "🇰🇷"},
        {name: "South Sudan", dial: "+211", flag: "🇸🇸"},
        {name: "Spain", dial: "+34", flag: "🇪🇸"},
        {name: "Sri Lanka", dial: "+94", flag: "🇱🇰"},
        {name: "Sudan", dial: "+249", flag: "🇸🇩"},
        {name: "Suriname", dial: "+597", flag: "🇸🇷"},
        {name: "Sweden", dial: "+46", flag: "🇸🇪"},
        {name: "Switzerland", dial: "+41", flag: "🇨🇭"},
        {name: "Syria", dial: "+963", flag: "🇸🇾"},
        {name: "Taiwan", dial: "+886", flag: "🇹🇼"},
        {name: "Tajikistan", dial: "+992", flag: "🇹🇯"},
        {name: "Tanzania", dial: "+255", flag: "🇹🇿"},
        {name: "Thailand", dial: "+66", flag: "🇹🇭"},
        {name: "Timor-Leste", dial: "+670", flag: "🇹🇱"},
        {name: "Togo", dial: "+228", flag: "🇹🇬"},
        {name: "Tonga", dial: "+676", flag: "🇹🇴"},
        {name: "Trinidad and Tobago", dial: "+1-868", flag: "🇹🇹"},
        {name: "Tunisia", dial: "+216", flag: "🇹🇳"},
        {name: "Turkey", dial: "+90", flag: "🇹🇷"},
        {name: "Turkmenistan", dial: "+993", flag: "🇹🇲"},
        {name: "Tuvalu", dial: "+688", flag: "🇹🇻"},
        {name: "Uganda", dial: "+256", flag: "🇺🇬"},
        {name: "Ukraine", dial: "+380", flag: "🇺🇦"},
        {name: "United Arab Emirates", dial: "+971", flag: "🇦🇪"},
        {name: "United Kingdom", dial: "+44", flag: "🇬🇧"},
        {name: "United States", dial: "+1", flag: "🇺🇸"},
        {name: "Uruguay", dial: "+598", flag: "🇺🇾"},
        {name: "Uzbekistan", dial: "+998", flag: "🇺🇿"},
        {name: "Vanuatu", dial: "+678", flag: "🇻🇺"},
        {name: "Vatican City", dial: "+379", flag: "🇻🇦"},
        {name: "Venezuela", dial: "+58", flag: "🇻🇪"},
        {name: "Vietnam", dial: "+84", flag: "🇻🇳"},
        {name: "Yemen", dial: "+967", flag: "🇾🇪"},
        {name: "Zambia", dial: "+260", flag: "🇿🇲"},
        {name: "Zimbabwe", dial: "+263", flag: "🇿🇼"}
    ];

    // Sort by name just in case
    countries.sort((a, b) => a.name.localeCompare(b.name));

    const select = document.getElementById("country_code");
    if (select) {
        countries.forEach(c => {
            const option = document.createElement("option");
            option.value = c.dial;
            option.textContent = `${c.flag} ${c.dial} (${c.name})`;
            // default to Pakistan
            if (c.name === "Pakistan") option.selected = true;
            select.appendChild(option);
        });
    }

    // Initialize reCAPTCHA if needed
    if (typeof grecaptcha !== 'undefined' && document.querySelector('.g-recaptcha')) {
        // reCAPTCHA is available and element exists
        console.log('reCAPTCHA initialized');
    }
});

// Toggle between email and phone fields
function toggleRegistrationMethod() {
    const method = document.querySelector('input[name="registration_method"]:checked').value;
    document.getElementById("email_field").style.display = method === "email" ? "block" : "none";
    document.getElementById("phone_field").style.display = method === "phone" ? "block" : "none";
}

// Password generation and handling
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

function togglePassword() {
    const pw1 = document.getElementById("user_password");
    const pw2 = document.getElementById("user_password_confirmation");

    const isPassword = pw1.type === "password";
    pw1.type = isPassword ? "text" : "password";
    pw2.type = isPassword ? "text" : "password";
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
