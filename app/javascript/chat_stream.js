function getCSRFToken() {
    const meta = document.querySelector("meta[name='csrf-token']");
    return meta && meta.getAttribute("content");
}

function attachChatListener() {
    const form = document.getElementById("chat-form");
    const input = document.getElementById("chat-input");
    const chatHistory = document.getElementById("chatHistory");

    if (!form || !input || !chatHistory) return;

    const conversationId = form.dataset.conversationId;
    const aiName = document.getElementById("chatMetadata")?.dataset.aiName || "AI";

    form.addEventListener("submit", function (e) {
        e.preventDefault();

        const message = input.value.trim();
        if (!message) return;

        input.value = "";

        // Show user's message
        const userBubble = document.createElement("div");
        userBubble.classList.add("chat-bubble", "user");
        userBubble.innerHTML = `<div><p><strong>You:</strong> ${message}</p></div>`;
        chatHistory.appendChild(userBubble);
        chatHistory.scrollTop = chatHistory.scrollHeight;

        // Bot response placeholder
        const aiBubble = document.createElement("div");
        aiBubble.classList.add("chat-bubble", "bot");
        const aiPara = document.createElement("p");
        aiBubble.appendChild(aiPara);
        chatHistory.appendChild(aiBubble);
        chatHistory.scrollTop = chatHistory.scrollHeight;

        // Streaming fetch
        fetch("/chat/stream", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Accept: "text/event-stream",
                "X-CSRF-Token": getCSRFToken()
            },
            body: JSON.stringify({
                conversation_id: conversationId,
                message: message
            })
        })
            .then(response => {
                const reader = response.body.getReader();
                const decoder = new TextDecoder("utf-8");
                let fullText = "";

                function read() {
                    reader.read().then(({ done, value }) => {
                        if (done) return;

                        const chunk = decoder.decode(value, { stream: true });
                        chunk.split("data: ").forEach(line => {
                            if (line.trim()) {
                                try {
                                    const json = JSON.parse(line.trim());
                                    if (json.response) {
                                        fullText += json.response;
                                        aiPara.textContent = `🤖 ${aiName}: ${fullText}`;
                                        chatHistory.scrollTop = chatHistory.scrollHeight;
                                    }
                                } catch (err) {
                                    console.error("Invalid JSON:", err);
                                }
                            }
                        });

                        read();
                    });
                }

                read();
            });
    });
}

// Initial and turbo-frame load trigger
document.addEventListener("DOMContentLoaded", attachChatListener);
document.addEventListener("turbo:frame-load", attachChatListener);