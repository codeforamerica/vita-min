import { appendAssociation, removeAssociation } from "./nested_attributes";

export function initNestedAttributesListeners() {
    $(document).on('click', '[data-link-to-remove-field]', function(e) {
        e.preventDefault();
        removeAssociation(this);
    });

    $(document).on('click', '[data-link-to-add-field]', function(e) {
        e.preventDefault();
        appendAssociation(this);
    });
}