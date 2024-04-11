export default function DollarAmountRoundingComponent() {
    const dollarInputs = document.querySelectorAll(".round-dollar-amount");

    dollarInputs.forEach((inputElement) => {
        function render() {
            const value = inputElement.value;

            if (!isNaN(value) && !isNaN(parseFloat(value))) {
                const rounded_value = Math.round(value);
                inputElement.value = rounded_value;
            }
        }

        inputElement.addEventListener("focusout", render);
        render();
    });
}
