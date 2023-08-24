
import { appendAssociation, removeAssociation } from "lib/nested_attributes/nested_attributes";

test("appendAssociation -- adds data-link-to-add contents to page", function (){
    document.body.innerHTML = `
        <div>
            <a id="test-field" 
                data-link-to-add-field-id='new' 
                data-link-to-add-field="<div data-link-to-add-field-id='new' class='append'>something</div>"
            >
                Test Link
            </a>
        </div>
    `;
    expect($('.append').length).toEqual(0);
    appendAssociation("#test-field");
    expect($('.append').length).toEqual(1);
});

test("removeAssociation -- hides association on page", function (){
    document.body.innerHTML = `
        <div class="section-to-hide">
            <input type="hidden" value="0" name="_destroy" />
            <a data-link-to-remove-field=".section-to-hide">Link</a>
        </div>
    `;

    expect($('.section-to-hide').css('display') == 'none').toEqual(false);
    removeAssociation("a");
    expect($('.section-to-hide').css('display') == 'none').toEqual(true);
})