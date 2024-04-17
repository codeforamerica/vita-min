export default function WarningForTextInputComponent() {
    const warningElements = document.querySelectorAll("[data-warning-for-text-input]");
    warningElements.forEach((warningElement) => {
        const inputElement = document.getElementById(warningElement.dataset.warningForTextInput);
        const permittedValues = JSON.parse(warningElement.dataset.permitted);

        function render() {
            const value = inputElement.value;
            if (permittedValues.includes(value)) {
                inputElement.classList.add("input-warning");
                $(warningElement).show('fast');
            } else {
                inputElement.classList.remove("input-warning");
                $(warningElement).hide('fast');
            }
        }
        inputElement.addEventListener("input", render);
        render();
    });
}
