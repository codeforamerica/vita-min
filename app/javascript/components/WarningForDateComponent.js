
export default function WarningForDateComponent() {
    const warningElements = document.querySelectorAll("[data-warning-for-date]");
    warningElements.forEach((warningElement) => {
        let { maxDate, minDate, warningForDate, requiredYear } = warningElement.dataset;
        maxDate = new Date(maxDate);
        minDate = new Date(minDate);
        const fields = ["year", "month", "day"].map((f) => {
            return document.querySelector(`[name="${warningForDate.replace("year", f)}"]`);
        });

        function show(){
            if (requiredYear) {
                const selectedYear = fields[0].value;
                return selectedYear && selectedYear !== requiredYear;
            }
            const date = new Date(...fields.map((s) => {
                return parseInt(s.value);
            }))
            if (!date.getTime()) {
                return false;
            }
            if (minDate.getTime() && date.getTime() < minDate.getTime()) {
                return true;
            }
            if (maxDate.getTime() && date.getTime() > maxDate.getTime()) {
                return true;
            }
            return false;
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
