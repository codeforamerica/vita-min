export function initTINTypeSelector() {
    const TINTypeSelector = window.TINTypeSelector;
    const SSNEmploymentCheckboxSelector = window.SSNEmploymentCheckboxSelector
    toggleSSNEmploymentCheckbox(TINTypeSelector);

    TINTypeSelector.addEventListener("change", function(e) {
        toggleSSNEmploymentCheckbox(e.target);
    });

    function toggleSSNEmploymentCheckbox(selector) {
        const no_employment_checkbox =  SSNEmploymentCheckboxSelector;
        if(selector.value === "ssn") {
            no_employment_checkbox.style.display = "block";
        } else {
            no_employment_checkbox.style.display = "none";
        }
    }
}
