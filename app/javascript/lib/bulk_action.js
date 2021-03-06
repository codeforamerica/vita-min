function changeCountDisplay(el, num) {
    el.textContent = String(num);
}

function getCheckedNum(form) {
    return [...form.elements].filter(el => el.checked).length;
}

function changeElDisplay(el, property) {
    el.style.display = property;
}

function handleCheckboxChange(formEl, takeActionCountEl, takeActionFooterEl) {
    changeCountDisplay(takeActionCountEl, getCheckedNum(formEl));
    if (getCheckedNum(formEl) >= 1) {
        changeElDisplay(takeActionFooterEl, "");
    } else if (getCheckedNum(formEl) === 0) {
        changeElDisplay(takeActionFooterEl, "none");
    }
}

function showTakeActionAll(formEl, totalTaxReturnsCount, takeActionAllEl) {
    if (getCheckedNum(formEl) == totalTaxReturnsCount) {
        changeElDisplay(takeActionAllEl, "none");
    } else {
        changeElDisplay(takeActionAllEl, "");
    }
}

export function initBulkAction() {
    const selectAllEl = document.querySelector('#bulk-edit-select-all');
    const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
    const formEl = document.querySelector('#take-action-form');
    const takeActionFooterEl = document.querySelector('#take-action-footer');
    const takeActionCountEl = document.querySelector('#take-action-count');
    const takeActionAllEl = document.querySelector('#take-action-all-returns');
    const totalTaxReturnsCount = document.querySelector('#take-action-all-count').textContent;

    handleCheckboxChange(formEl, takeActionCountEl, takeActionFooterEl);

    if (selectAllEl) {
        selectAllEl.addEventListener('change', () => {
            if (selectAllEl.checked) {
                allCheckboxEls.forEach(checkboxEl => checkboxEl.checked = true);
                showTakeActionAll(formEl, totalTaxReturnsCount, takeActionAllEl)
            } else {
                allCheckboxEls.forEach(checkboxEl => checkboxEl.checked = false);
                // Hide take action all no matter what
                changeElDisplay(takeActionAllEl, "none");
            }

            handleCheckboxChange(formEl, takeActionCountEl, takeActionFooterEl);
        });
    }

    if (allCheckboxEls.length > 0) {
        allCheckboxEls.forEach((el) => {
            el.addEventListener('change', () => {
                handleCheckboxChange(formEl, takeActionCountEl, takeActionFooterEl);
            });
        });
    }
}
