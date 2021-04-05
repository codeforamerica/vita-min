import Tagify from '@yaireo/tagify'

export function initTaggableNote() {
    // enable feature-flagging
    // const url = new URLSearchParams(location.search);
    // if (!url.has("test-tagging")) { return }

    const input = document.querySelector('.taggable-note');
    if (!input) { return }

    const whitelist = window.taggableItems.map((i) => {
        if (!i.value) { i.value = i.id }; // whitelist items MUST have a value property
        return i;
    })

    // initialize Tagify
    // init Tagify script on the above inputs
    const tagify = new Tagify(input, {
        mode: 'mix',  // <--  Enable mixed-content
        pattern: /@/,  // <--  Text starting with @ (if single, String can be used here)
        tagTextProp: 'name',  // <-- the default property (from whitelist item) for the text to be rendered in a tag element.
        // Array for initial interpolation, which allows only these tags to be used
        whitelist: whitelist,
        enforceWhitelist: true,
        dropdown : {
            enabled: 0,
            position: 'text', // <-- render the suggestions list next to the typed text ("caret")
            mapValueTo: 'name_with_role_and_entity', // <-- similar to above "tagTextProp" setting, but for the dropdown items
            highlightFirst: true  // automatically highlights first suggestion item in the dropdown
        },
        callbacks: {
            add: console.log, // callback when adding a tag
            remove: console.log   // callback when removing a tag
        }
    });

    tagify.on('input', function(e){
        console.log( tagify.value )
        console.log('mix-mode "input" event value: ', e.detail)
    });

    tagify.on('add', function(e){
        console.log(e)
    });
}
