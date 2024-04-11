export default function DollarAmountRoundingComponent() {
    function replaceValue() {
        const value = this.value;

        if (!isNaN(value) && !isNaN(parseFloat(value))) {
            const rounded_value = Math.round(value);
            this.value = rounded_value;
        }
    }

    document.querySelectorAll(".round-dollar-amount").forEach((inputElement) => {
        inputElement.addEventListener("focusout", replaceValue);
    });
}
