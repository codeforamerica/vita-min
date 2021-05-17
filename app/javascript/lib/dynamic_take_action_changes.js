export function initTakeActionOnChangeHandlers(formName) {

    $(`#hub_${formName}_form_status, #hub_${formName}_form_locale`).change(function() {
        $(".hub-form :input").prop("disabled", true);
        const pathname = window.location.pathname.replace("update", "edit");
        window.location.replace(pathname + "?" + searchParamsString(formName) + "#status");
    });
}
function searchParamsString(formName) {
    const searchParams = new URLSearchParams();
    const taxReturnId = $(`#hub_${formName}_form_tax_return_id`).val();
    const selectedStatus = $(`#hub_${formName}_form_status`).val();
    const selectedAssignee = $(`#hub_${formName}_form_assigned_user_id`).val();
    const locale = $(`#hub_${formName}_form_locale`).val();

    if (taxReturnId) { searchParams.set('tax_return[id]', taxReturnId) }
    if (selectedStatus) { searchParams.set('tax_return[status]', selectedStatus) }
    if (selectedAssignee) { searchParams.set('tax_return[assigned_user_id]', selectedAssignee) }

    if (locale) { searchParams.set("tax_return[locale]", locale) }
    return searchParams.toString();
}