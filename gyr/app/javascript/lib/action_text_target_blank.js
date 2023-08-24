export function addTargetBlankToLinks() {
    document.querySelectorAll('.trix-content a').forEach(function(link) {
        if (link.host !== window.location.host) {
            link.target = "_blank"
            link.rel = "noopener nofollow"
        }
    });
}