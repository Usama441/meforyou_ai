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
        aiPara.innerHTML = `<strong>🤖 ${aiName}:</strong> <span class="ai-response"></span>`;
        aiBubble.appendChild(aiPara);
        chatHistory.appendChild(aiBubble);
        const responseSpan = aiPara.querySelector(".ai-response");

        // Stream from backend
                    // Log what we're sending to help debug
                    console.log("Sending chat request with:", {
            conversation_id: conversationId,
            message: message
                    });

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
                if (!response.ok) throw new Error("Response failed: " + response.status);

                const reader = response.body.getReader();
                const decoder = new TextDecoder("utf-8");
                let fullText = "";

                function read() {
                    reader.read().then(({ done, value }) => {
                        if (done) return;

                        const chunk = decoder.decode(value, { stream: true });
                        const lines = chunk.split("\n").filter(line => line.startsWith("data: "));

                        lines.forEach(line => {
                            try {
                                const jsonStr = line.replace("data: ", "").trim();
                                if (jsonStr === "[DONE]") return;

                                console.log("Received JSON string:", jsonStr);
                                const json = JSON.parse(jsonStr);
                                console.log("Parsed JSON:", json);

                                // Check if this is an error response
                                if (json.error) {
                                    responseSpan.innerHTML = `<span style="color: #ff5555;">${json.response}</span>`;
                                    console.error("Error from API:", json.response);
                                    return;
                                }

                                const delta = json.response;
                                const isError = json.error;

                                if (delta) {
                                    if (isError) {
                                        // Handle error response
                                        responseSpan.innerHTML = `<span class="error-message">${delta}</span>`;
                                        console.error("API error:", delta);
                                    } else {
                                        // Handle normal response
                                        fullText += delta;
                                        responseSpan.textContent = fullText;
                                        chatHistory.scrollTop = chatHistory.scrollHeight;
                                    }
                                }
                            } catch (err) {
                                console.error("Invalid JSON:", err);
                            }
                        });

                        // Continue reading stream
                        read();
                    });
                }

                read();
            })
            .catch(err => {
                responseSpan.textContent = "❌ Error: " + err.message;
                console.error("Fetch error:", err);
                // Log detailed error information
                console.log("Conversation ID:", conversationId);
                console.log("Message sent:", message);
            });
    });
}

document.addEventListener("DOMContentLoaded", attachChatListener);
document.addEventListener("turbo:frame-load", attachChatListener);
