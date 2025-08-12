import "./chat_stream";
import "./custom_select";
import "./form_validation";
import "./turbo_debug";

console.log("📦 JS Loaded Successfully!");

document.addEventListener("DOMContentLoaded", function () {
    const toggle = document.getElementById('darkModeToggle');
    const body = document.body;

    // Dark mode toggle
    if (toggle) {
        if (localStorage.getItem('theme') === 'dark') {
            body.classList.add('dark-mode');
            toggle.checked = true;
        }

        toggle.addEventListener('change', function () {
            if (this.checked) {
                body.classList.add('dark-mode');
                localStorage.setItem('theme', 'dark');
            } else {
                body.classList.remove('dark-mode');
                localStorage.setItem('theme', 'light');
            }
        });
    }

    // Auto scroll chat history
    const chatHistory = document.getElementById("chatHistory");
    if (chatHistory) {
        chatHistory.scrollTop = chatHistory.scrollHeight;
    }

    // Emoji picker toggle
    const emojiBtn = document.getElementById('emojiBtn');
    const emojiPicker = document.getElementById('emojiPicker');

    if (emojiBtn && emojiPicker) {
        emojiBtn.addEventListener('click', function () {
            emojiPicker.style.display = emojiPicker.style.display === 'none' ? 'block' : 'none';
            emojiPicker.innerHTML = '😀 😁 😂 🤣 😍 😎 🤔 🙄 😡 😢 ❤️ 🎉'
                .split(' ')
                .map(e => `<span class="emoji-item" style="cursor:pointer;padding:4px;font-size:20px;">${e}</span>`)
                .join('');
        });
    }
});
