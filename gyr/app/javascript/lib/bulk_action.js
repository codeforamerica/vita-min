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

export function initBulkAction() {
    const selectAllEl = document.querySelector('#bulk-edit-select-all');
    const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
    const formEl = document.querySelector('#take-action-form');
    const takeActionFooterEl = document.querySelector('#take-action-footer');
    const takeActionCountEl = document.querySelector('#take-action-count');
    const takeActionAllEl = document.querySelector('#take-action-all-returns');

    handleCheckboxChange(formEl, takeActionCountEl, takeActionFooterEl);

    if (selectAllEl) {
        selectAllEl.addEventListener('change', () => {
            const useTakeActionAllEl = selectAllEl.dataset['multiPage'] === 'true';
            if (selectAllEl.checked) {
                allCheckboxEls.forEach(checkboxEl => checkboxEl.checked = true);
                if (useTakeActionAllEl) {
                    takeActionAllEl.classList.remove('hidden')
                }
            } else {
                allCheckboxEls.forEach(checkboxEl => checkboxEl.checked = false);
                if (useTakeActionAllEl) {
                    takeActionAllEl.classList.add('hidden')
                }
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
