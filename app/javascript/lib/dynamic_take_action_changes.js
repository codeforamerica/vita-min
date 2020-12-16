export function initTakeActionOnChangeHandlers() {
    $("#hub_take_action_form_status, #hub_take_action_form_locale").change(function() {
        $(".hub-form :input").prop("disabled", true);
        const pathname = window.location.pathname.replace("update_take_action", "edit_take_action");
        window.location.replace(pathname + "?" + searchParamsString() + "#status");
    });
}

function searchParamsString() {
    const searchParams = new URLSearchParams();
    const taxReturnId = $("#hub_take_action_form_tax_return_id").val();
    const selectedStatus = $("#hub_take_action_form_status").val();
    const locale = $("#hub_take_action_form_locale").val();

    if (taxReturnId) { searchParams.set('tax_return[id]', taxReturnId) }
    if (selectedStatus) { searchParams.set('tax_return[status]', selectedStatus) }
    if (locale) { searchParams.set("tax_return[locale]", locale) }
    return searchParams.toString();
}