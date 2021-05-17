import { initTakeActionOnChangeHandlers } from "lib/dynamic_take_action_changes";

const oldWindowLocation = window.location

beforeAll(() => {
    document.body.innerHTML = `
        <div class="hub-form">
            <select id="hub_take_action_form_tax_return_id">
                <option value="1" selected>2019</option>
                <option value="2">2018</option>
            </select>
            <select id="hub_take_action_form_status">
                <option value="status-a" selected>Status A</option>
                <option value="status-b">Status B</option>
            </select>
            <select id="hub_take_action_form_locale" >
                <option value="en" selected>English</option>
                <option value="es">Spanish</option>
            </select>
        </div>
    `;
    delete window.location

    window.location = Object.defineProperties(
        {},
        {
            ...Object.getOwnPropertyDescriptors(oldWindowLocation),
            replace: {
                configurable: true,
                value: jest.fn(),
            },
            pathname: {
                configurable: true,
                value: "http://example.com/update_take_action"
            }
        },
    )
})

beforeEach(() => {
    window.location.replace.mockReset()
})

afterAll(() => {
    // restore `window.location` to the `jsdom` `Location` object
    window.location = oldWindowLocation
})

test("changing status initiates a location change with status and locale params", function (){
    initTakeActionOnChangeHandlers("take_action");
    $('select#hub_take_action_form_status').val('status-b').trigger('change');
    expect(window.location.replace).toHaveBeenCalledWith("http://example.com/edit_take_action?tax_return%5Bid%5D=1&tax_return%5Bstatus%5D=status-b&tax_return%5Blocale%5D=en#status")
});

test("changing status initiates a location change with status and locale params", function (){
    initTakeActionOnChangeHandlers("take_action");
    $('select#hub_take_action_form_locale').val('es').trigger('change');
    expect(window.location.replace).toHaveBeenCalledWith("http://example.com/edit_take_action?tax_return%5Bid%5D=1&tax_return%5Bstatus%5D=status-b&tax_return%5Blocale%5D=es#status")
});

