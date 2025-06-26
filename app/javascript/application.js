document.addEventListener('DOMContentLoaded', function () {
    const toggle = document.getElementById('darkModeToggle');
    const body = document.body;

    // Load previous theme
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

    // Auto-scroll to bottom
    const chatHistory = document.getElementById("chatHistory");
    if (chatHistory) {
        chatHistory.scrollTop = chatHistory.scrollHeight;
    }

    // Emoji picker (simple Unicode demo)
    const emojiBtn = document.getElementById('emojiBtn');
    const emojiPicker = document.getElementById('emojiPicker');
    const chatInput = document.getElementById('chatInput');

    emojiBtn.addEventListener('click', function () {
        emojiPicker.style.display = emojiPicker.style.display === 'none' ? 'block' : 'none';
        emojiPicker.innerHTML = '😀 😁 😂 🤣 😍 😎 🤔 🙄 😡 😢 ❤️ 🎉'.split(' ').map(e => {
            return `<span class="emoji-item" style="cursor:pointer;padding:4px;font-size:20px;">${e}</span>`;
        }).join('');
    });

    emojiPicker.addEventListener('click', function (e) {
        if (e.target.classList.contains('emoji-item')) {
            chatInput.value += e.target.textContent;
            chatInput.focus();
        }
    });
});
