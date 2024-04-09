
export default function WarningForDateComponent() {
    const warningElements = document.querySelectorAll("[data-warning-for-date]");
    warningElements.forEach((warningElement) => {
        let { minDate, warningForDate, requiredYear } = warningElement.dataset;
        minDate = new Date(minDate);
        const fields = ["year", "month", "day"].map((f) => {
            return document.querySelector(`[name="${warningForDate}[dob_${f}]"]`);
        });

        function show(){
            if (requiredYear) {
                const selectedYear = fields[0].value;
                return selectedYear && selectedYear !== requiredYear;
            }
            const date = new Date(...fields.map((s) => {
                return parseInt(s.value);
            }))
            return date.getTime() < minDate.getTime();
        }
        function render(){
            $(warningElement)[show() ? "show" : "hide"]("slow");
        }

        fields.forEach((f) => {
            f.addEventListener("change", render);
        })
        render();
    });
}
