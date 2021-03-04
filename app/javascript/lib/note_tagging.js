import Tagify from '@yaireo/tagify'

export function initTaggableNote() {
    // var whitelist = [
    //     { id: 100, text: 'Nicole', title: 'Nicole Rappin' },
    //     { id: 200, text: 'Shannon', title: 'Shannon Byrne' },
    //     { id: 300, text: 'Yvonne', title: 'Yvonne Fong' },
    //     { id: 400, text: 'Kelly', title: 'Kelly McBride' },
    //     { id: 500, text: 'Ben', title: 'Ben Golder' },
    //     { id: 600, text: 'Jenny', title: 'Jenny Heath' },
    //     { id: 700, text: 'Rae', title: 'Rae Pilarski' },
    //     { id: 800, text: 'Em', title: 'Em Barnado-Shaw' },
    //     { id: 900, text: 'Asheesh', title: 'Asheesh Laroia' },
    //     { id: 1000, text: 'Annelise', title: "Annelise G" }
    // ]

    const whitelist = window.taggableItems;

    // initialize Tagify
    let input = document.querySelector('.taggable-note'),
        // init Tagify script on the above inputs
        tagify = new Tagify(input, {
            mode: 'mix',  // <--  Enable mixed-content
            enforceWhitelist: true,
            pattern: /@/,  // <--  Text starting with @ or # (if single, String can be used here)
            tagTextProp: 'name',  // <-- the default property (from whitelist item) for the text to be rendered in a tag element.
            whitelist: whitelist,

            dropdown : {
                enabled: 0,
                position: 'all', // <-- render the suggestions list next to the typed text ("caret")
                mapValueTo: 'name', // <-- similar to above "tagTextProp" setting, but for the dropdown items
                highlightFirst: true  // automatically highlights first sugegstion item in the dropdown
            },
            callbacks: {
                add: console.log,  // callback when adding a tag
                remove: console.log   // callback when removing a tag
            }
        })

    tagify.on('input', function(e){
        var prefix = e.detail.prefix;

        // first, clean the whitlist array, because the below code, while not, might be async,
        // therefore it should be up to you to decide WHEN to render the suggestions dropdown
        // tagify.settings.whitelist.length = 0;

        if(prefix){
            if(prefix == '@')
                tagify.settings.whitelist = whitelist;

            if( e.detail.value.length > 1 )
                tagify.dropdown.show.call(tagify, e.detail.value);
        }
    })

    tagify.on('add', function(e){
        console.log(e)
    })
}
