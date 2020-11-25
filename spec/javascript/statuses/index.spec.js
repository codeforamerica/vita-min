import {setUrlBasedOnStatus} from "../../../app/javascript/statuses";

test("Sets window.location based on selected status", function () {
    delete window.location;
    window.location = new URL("http://example.com/some/url?query=param&tax_return%5Bstatus%5D=old_status");

    document.body.innerHTML = `
        <select id="some_id">
            <optgroup>
                <option value="old_status">Some Old Status</option>
            </optgroup>
            <optgroup>
                <option selected value="new_status">A New Status</option>
            </optgroup>
        </select>
    `;

    setUrlBasedOnStatus("#some_id");

    expect(window.location.href).toBe("http://example.com/some/url?query=param&tax_return%5Bstatus%5D=new_status");
});