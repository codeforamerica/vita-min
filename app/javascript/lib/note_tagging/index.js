import Tagify from '@yaireo/tagify'
import { removeMentionedId, addMentionedId } from "./callbacks";

export function initTaggableNote() {
    // limit with feature-flagging
    const url = new URLSearchParams(location.search);
    if (!url.has("test-tagging")) { return }

    const input = document.querySelector('.taggable-note');

    const whitelist = window.taggableItems.map((i) => {
        if (!i.value) { i.value = i.id }; // whitelist items MUST have a value property
        return i;
    });

    new Tagify(input, {
        mode: 'mix',  // <--  Enable mixed-content
        pattern: /@/,  // <--  Text starting with @ (if single, String can be used here)
        tagTextProp: 'name',  // <-- Defines which attr is used as the display value
        // Array for initial interpolation, which allows only these tags to be used
        whitelist: whitelist,
        enforceWhitelist: true,
        dropdown : {
            enabled: 0,
            position: 'text', // <-- render the suggestions list next to the typed text
            mapValueTo: 'name_with_role_and_entity', // <-- defines which attr is used for dropdown items
            highlightFirst: true  // automatically highlights first suggestion item in the dropdown
        },
        callbacks: {
            add: addMentionedId,
            remove: removeMentionedId
        }
    });
}