document.addEventListener("DOMContentLoaded", function () {
    const form = document.getElementById("chat-form");
    const chatInput = document.getElementById("chatInput");
    const chatHistory = document.getElementById("chatHistory");
    const aiName = window.currentAIName || "AI";  // ← from embedded Ruby script tag

    if (!form || !chatInput || !chatHistory) {
        console.warn("Chat form or history not found.");
        return;
    }

    form.addEventListener("submit", function (e) {
        e.preventDefault();

        const message = chatInput.value.trim();
        if (message === "") return;

        const userBubble = `
          <div class="chat-bubble user">
            <div class="avatar">👤</div>
            <div>
              <p><strong>You:</strong> ${message}</p>
              <span class="timestamp">${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
            </div>
          </div>
        `;
        chatHistory.insertAdjacentHTML("beforeend", userBubble);

        const aiBubble = document.createElement("div");
        aiBubble.className = "chat-bubble bot";
        aiBubble.innerHTML = `
          <div class="avatar">🤖</div>
          <div>
            <p><strong>${aiName}:</strong> <span id="streamedText">${aiName} is typing</span></p>
            <span class="timestamp">${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
          </div>
        `;
        chatHistory.appendChild(aiBubble);
        const streamedText = aiBubble.querySelector("#streamedText");

        // Typing animation with AI name
        let dots = "";
        let startedStreaming = false;
        const dotInterval = setInterval(() => {
            if (!startedStreaming) {
                dots = dots.length < 3 ? dots + "." : "";
                streamedText.textContent = `is typing${dots}`;
            }
        }, 400);

        chatHistory.scrollTop = chatHistory.scrollHeight;
        chatInput.value = "";

        fetch("/chat/stream", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            },
            body: `message=${encodeURIComponent(message)}`
        })
            .then(response => {
                const reader = response.body.getReader();
                const decoder = new TextDecoder();
                let buffer = "";
                let displayBuffer = "";
                let isRendering = false;

                function renderChunk() {
                    if (displayBuffer.length > 0) {
                        streamedText.textContent += displayBuffer;
                        displayBuffer = "";
                        chatHistory.scrollTop = chatHistory.scrollHeight;
                        requestAnimationFrame(renderChunk);
                    } else {
                        isRendering = false;
                    }
                }

                function scheduleRender() {
                    if (!isRendering) {
                        isRendering = true;
                        requestAnimationFrame(renderChunk);
                    }
                }

                function read() {
                    reader.read().then(({ done, value }) => {
                        if (done) {
                            clearInterval(dotInterval);
                            return;
                        }

                        buffer += decoder.decode(value, { stream: true });
                        const lines = buffer.split("\n");
                        buffer = lines.pop();

                        lines.forEach(line => {
                            if (line.trim().startsWith("data:")) {
                                try {
                                    const json = JSON.parse(line.replace("data:", "").trim());
                                    if (json.response) {
                                        // First response chunk received → stop animation and overwrite
                                        if (!startedStreaming) {
                                            streamedText.textContent = "";
                                            startedStreaming = true;
                                            clearInterval(dotInterval);
                                        }
                                        displayBuffer += json.response;
                                        scheduleRender();
                                    }
                                } catch (err) {
                                    console.warn("Invalid JSON:", line);
                                }
                            }
                        });

                        read();
                    });
                }

                read();
            })
            .catch(error => {
                clearInterval(dotInterval);
                console.error("Fetch error:", error);
                streamedText.textContent = "Error: " + error.message;
            });
    });
});
