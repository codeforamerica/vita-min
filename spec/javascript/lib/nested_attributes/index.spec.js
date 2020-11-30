import { initNestedAttributesListeners } from "lib/nested_attributes";

jest.mock('lib/nested_attributes/nested_attributes');
import { appendAssociation, removeAssociation } from "lib/nested_attributes/nested_attributes";

test("after event listeners initialized, clicking elements triggers method calls", function (){
    document.body.innerHTML = `
        <div>
            <a data-link-to-add-field="<div id='appended'>something</div>"></a>
            <a data-link-to-remove-field="#appended"></a>
        </div>
    `;

    initNestedAttributesListeners();

    $("a[data-link-to-add-field]")[0].click();
    expect(appendAssociation).toBeCalledTimes(1);

    $("a[data-link-to-remove-field]")[0].click();
    expect(removeAssociation).toBeCalledTimes(1);
});

