import Tagify from '@yaireo/tagify'
import { removeMentionedId, addMentionedId } from "./callbacks";

export function initTaggableNote() {
    const input = document.querySelector('.taggable-note');

    const whitelist = window.taggableItems.map((i) => {
        if (!i.value) { i.value = i.id }; // whitelist items MUST have a value property
        return i;
    });

    new Tagify(input, {
        mode: 'mix',  // <--  Enable mixed-content
        pattern: /@/,  // <--  Text starting with @ (if single, String can be used here)
        tagTextProp: 'name',  // <-- defines which attr is used as the tag display value
        // Array for initial interpolation, which allows only these tags to be used
        whitelist: whitelist,
        enforceWhitelist: true,
        dropdown : {
            enabled: 0,
            position: 'text', // <-- render the suggestions list next to the typed text
            mapValueTo: 'name_with_role_and_entity', // <-- defines which attr is used to display dropdown items
            highlightFirst: true  // automatically highlights first suggestion item in the dropdown
        },
        callbacks: {
            add: addMentionedId,
            remove: removeMentionedId
        }
    });
}

export function initMultiSelectVitaPartner() {
    const input = document.querySelector('.multi-select-vita-partner');

    new Tagify(input, {
        tagTextProp: 'name',  // <-- defines which attr is used as the tag display value
        // Array for initial interpolation, which allows only these tags to be used
        whitelist: window.taggableItems,
        enforceWhitelist: true,
        dropdown : {
            classname: "multi-select-dropdown",
            enabled: 0,
            mapValueTo: 'name', // <-- defines which attr is used to display dropdown items
            searchKeys: ['name'], // <-- defines the attr used to search for in dropdown
            highlightFirst: true,  // <-- automatically highlights first suggestion item in the dropdown
            closeOnSelect: false, // <-- keep dropdown open after selection
            maxItems: window.taggableItems.length, // <-- render all available items for the dropdown
            position: 'text', // <-- render the suggestions list next to the text carat
        },
        templates: {
            dropdownItem: function(item){
                return `<div ${this.getAttributes(item)}
                    class='${this.settings.classNames.dropdownItem}'
                    tabindex="0"
                    role="option">
                        <div class='${item.parentName ? "parent" : ""}'>${item.parentName || ''}</div>
                        <div class='${item.parentName ? "site" : "org"}'>${item.value}</div>
                    </div>`
            },
        }
    });
}

export function initMultiSelectState() {
    const input = document.querySelector('.multi-select-state');

    new Tagify(input, {
        // Array for initial interpolation, which allows only these tags to be used
        whitelist: window.taggableItems,
        enforceWhitelist: true,
        dropdown : {
            classname: "multi-select-dropdown",
            enabled: 0,
            highlightFirst: true,  // <-- automatically highlights first suggestion item in the dropdown
            closeOnSelect: false, // <-- keep dropdown open after selection
            maxItems: window.taggableItems.length, // <-- render all available items for the dropdown
            position: 'text', // <-- render the suggestions list next to the text carat
        },
    });
}