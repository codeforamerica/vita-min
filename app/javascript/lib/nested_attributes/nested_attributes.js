export function appendAssociation(selector) {
    let fields_html, regexp, time;
    // Replace server-rendered static field-id with dynamic unique value (time) to ensure
    // we can persist multiple new elements at once.
    time = new Date().getTime();
    regexp = new RegExp($(selector).data('link-to-add-field-id'), 'g');
    fields_html = $(selector).data('link-to-add-field').replace(regexp, time);
    $(selector).before(fields_html);
}

export function removeAssociation(selector) {
    $(selector).prev('input[type=hidden]').val('1');
    const target = $(selector).data('link-to-remove-field');
    const $field = $(selector).closest(target);
    return $field.hide();
}