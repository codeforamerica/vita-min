function statusDropdown() {
    return document.getElementById("hub_take_action_form_status");
}

export function setUrlBasedOnStatus(dropdownSelector) {
    let statusDropdown = document.querySelector(dropdownSelector);
    let url = new URL(window.location.href);
    url.searchParams.set('tax_return[status]', statusDropdown.value);
    window.location = url;
}

export function bindStatusChangeEventListener(dropdownSelector) {
    statusDropdown().addEventListener('change', () => setUrlBasedOnStatus(dropdownSelector));
}