
export default function WarningForDateComponent() {
    const warningElements = document.querySelectorAll("[data-warning-for-date]");
    warningElements.forEach((warningElement) => {
        let { minDate, warningForDate } = warningElement.dataset;
        minDate = new Date(minDate);
        const fields = ["year", "month", "day"].map((f) => {
            return document.querySelector(`[name="${warningForDate}[dob_${f}]"]`);
        });

        function render(){
            const date = new Date(...fields.map((s) => {
                return parseInt(s.value);
            }))
            const show = date.getTime() < minDate.getTime();
            $(warningElement)[show ? "show" : "hide"]("slow");
        }

        fields.forEach((f) => {
            f.addEventListener("change", render);
        })
        render();
    });
}
