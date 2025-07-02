document.addEventListener("turbo:load", function () {
    document.addEventListener("turbo:before-fetch-request", (e) => {
        console.log("⚡ Turbo frame request sent", e);
    });

    document.addEventListener("turbo:before-frame-render", (e) => {
        console.log("✅ Turbo frame will update", e);
    });
});
