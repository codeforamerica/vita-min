export function addMentionedId(e) {
    const trackingInput = document.querySelector(window.taggableTrackingSelector);
    const ids = trackingInput.value.length ? trackingInput.value.split(",") : [];
    if (ids.includes(e.detail.data.id)) { return }

    ids.push(e.detail.data.id); // add selected element to the array
    trackingInput.value = ids.join(",");
}

export function removeMentionedId(e) {
    const trackingInput = document.querySelector(window.taggableTrackingSelector);
    if (!trackingInput.value.length) { return }
    let ids = trackingInput.value.split(",");
    const index = ids.findIndex(id => id == e.detail.data.id);

    ids.splice(index, 1); // remove the element from the array
    trackingInput.value = ids.join(",");
}