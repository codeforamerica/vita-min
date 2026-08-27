const STORAGE_KEY_PREFIX = "dismissibleBannerDismissed:";

function initDismissibleBanner() {
    const banners = document.querySelectorAll("[data-dismissible-banner]");

    banners.forEach((banner) => {
        const bannerId = banner.dataset.dismissibleBannerId || "default";
        const storageKey = `${STORAGE_KEY_PREFIX}${bannerId}`;

        if (localStorage.getItem(storageKey) === "true") {
            banner.classList.add("is-hidden");
            return;
        }

        const closeBtn = banner.querySelector("[data-dismissible-banner-close]");
        if (!closeBtn) return;

        closeBtn.addEventListener("click", () => {
            banner.classList.add("is-hidden");
            localStorage.setItem(storageKey, "true");
        });
    });
}

export { initDismissibleBanner };