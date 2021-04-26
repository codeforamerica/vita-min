function changeCountDisplay(el, num) {
    el.textContent = String(num);
}

function getCheckedNum(form) {
    return [...form.elements].filter(el => el.checked).length;
}

function changeElDisplay(el, property) {
    el.style.display = property;
}

export function initBulkAction() {
    const selectAllEl = document.querySelector('#bulk-edit-select-all');
    const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
    const formEl = document.querySelector('#take-action-form');
    const takeActionFooterEl = document.querySelector('#take-action-footer');
    const takeActionCountEl = document.querySelector('#take-action-count');

    if (selectAllEl) {
        selectAllEl.addEventListener('change', () => {
            if (selectAllEl.checked) {
                allCheckboxEls.map(checkboxEl => checkboxEl.checked = true);
                changeElDisplay(takeActionFooterEl, "");
            } else {
                allCheckboxEls.map(checkboxEl => checkboxEl.checked = false);
                changeElDisplay(takeActionFooterEl, "none");
            }
            changeCountDisplay(takeActionCountEl, getCheckedNum(formEl));
        });
    }

    if (allCheckboxEls.length > 0) {
        allCheckboxEls.forEach((el) => {
            el.addEventListener('change', () => {
                if (el.checked && getCheckedNum(formEl) === 1) {
                    changeElDisplay(takeActionFooterEl, "");
                } else if (getCheckedNum(formEl) === 0) {
                    changeElDisplay(takeActionFooterEl, "none");
                }
                changeCountDisplay(takeActionCountEl, getCheckedNum(formEl));
            });
        });
    }
}