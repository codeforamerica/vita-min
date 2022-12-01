export function appendAssociation(selector) {
    // Replace server-rendered static field-id with dynamic unique value (time) to ensure
    // we can persist multiple new elements at once.
    let time = new Date().getTime();
    let regexp = new RegExp($(selector).data('link-to-add-field-id'), 'g');
    let fields_html = $(selector).data('link-to-add-field').replace(regexp, time);
    let target = $(selector).data('link-to-add-field-target')
    if (target) {
        $(target).append(fields_html);
    } else {
        $(selector).before(fields_html);
    }
}

export function removeAssociation(selector) {
    $(selector).prev('input[type=hidden]').val('1');
    const target = $(selector).data('link-to-remove-field');
    const $field = $(selector).closest(target);
    return $field.hide();
}