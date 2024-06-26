
export default function WarningForSelectComponent() {
    const warningElements = document.querySelectorAll("[data-warning-for-select]");
    warningElements.forEach((warningElement) => {
        const selectElement = document.getElementById(warningElement.dataset.warningForSelect);
        const permittedValues = JSON.parse(warningElement.dataset.permitted);

        function render() {
            const value = selectElement.value;
            if (permittedValues.includes(value)) {
                selectElement.classList.add("input-warning");
                $(warningElement).show('fast');
            } else {
                selectElement.classList.remove("input-warning");
                $(warningElement).hide('fast');
            }
        }
        selectElement.addEventListener("change", render);
        render();
    });
}
