
    document.addEventListener("DOMContentLoaded", () => {
    const input = document.getElementById("contact_input");
    const countryInfo = document.getElementById("country_info");

    const countryData = {
    "+92": { name: "Pakistan", flag: "🇵🇰" },
    "+91": { name: "India", flag: "🇮🇳" },
    "+1":  { name: "United States", flag: "🇺🇸" },
    "+44": { name: "United Kingdom", flag: "🇬🇧" },
    // Add more as needed
};

    input.addEventListener("input", () => {
    const value = input.value.trim();

    // Reset
    countryInfo.innerHTML = "";

    // Phone number detection
    if (/^\+?\d+$/.test(value)) {
    for (const code in countryData) {
    if (value.startsWith(code)) {
    const data = countryData[code];
    countryInfo.innerHTML = `${data.flag} <strong>${data.name}</strong>`;
    break;
}
}
}
});
});

