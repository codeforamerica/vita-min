import { limitTextMessageLength } from 'lib/text_message_length_limiter';
const fs = require("fs");
const path = require("path");


describe('text message form with length limiter', () => {
    const { body } = document;
    const lorumIpsum = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus,"

    let component;
    let submitButton;
    let textarea;

    describe('without a radio button that disables the length limiter', () => {
        const TEMPLATE = fs.readFileSync(path.join(__dirname, "/template.html"));
        let counter;

        beforeEach(() => {
            body.innerHTML = TEMPLATE;
            textarea = body.querySelector("textarea.text-message-body");
            component = body.querySelector(".text-message-length-limiter")
            counter = body.querySelector('[data-target="length-counter"]');
            submitButton = body.querySelector("input[type='submit']");
        });

        test("it sets the current length into the counter on initialization (less than 900)", () => {
            textarea.value = "123456789"
            limitTextMessageLength();
            expect(counter.innerHTML).toEqual("9")
            expect(counter.classList.length).toEqual(0)
            expect(submitButton.disabled).toEqual(false)

        });

        test("it sets the current length into the counter on initialization (= 900)", () => {
            textarea.value = lorumIpsum
            limitTextMessageLength();
            expect(counter.innerHTML).toEqual("900");
            expect(component.classList).toContain('text--error');
            expect(submitButton.disabled).toEqual(true);
        });

        test("it sets the current length into the counter on initialization (= 905)", () => {
            textarea.value = lorumIpsum + "12345"
            limitTextMessageLength();
            expect(counter.innerHTML).toEqual("905");
            expect(component.classList).toContain('text--error');
            expect(submitButton.disabled).toEqual(true);
        });

        test("changing the length and triggering an input event (9 -> 900)", () => {
            textarea.value = "123456789"
            limitTextMessageLength();
            expect(counter.innerHTML).toEqual("9");

            textarea.value = lorumIpsum;
            let event = new Event('input');
            textarea.dispatchEvent(event);
            expect(counter.innerHTML).toEqual("900");
            expect(component.classList).toContain('text--error');
            expect(submitButton.disabled).toEqual(true);
        });
    });

    describe('with a radio button that disables the length limiter', () => {
        let messageLengthDisableRadioButton;
        const TEMPLATE = fs.readFileSync(path.join(__dirname, "/template_with_radio_button.html"));

        beforeEach(() => {
            body.innerHTML = TEMPLATE;
            messageLengthDisableRadioButton = body.querySelector(".message-length-limiter-disable");
            component = body.querySelector(".text-message-length-limiter")
            submitButton = body.querySelector("input[type='submit']");
            textarea = body.querySelector("textarea.text-message-body");
        });

        test("when the radio button that disables the limiter is checked, the limiter is disabled", () => {
            messageLengthDisableRadioButton.checked = true;
            limitTextMessageLength();
            expect(component.classList).toContain('hidden')
            expect(submitButton.disabled).toEqual(false);
        });

        test("when the radio button that disables the limiter is not checked, the limiter is enabled", () => {
            textarea.value = lorumIpsum
            messageLengthDisableRadioButton.checked = false;
            limitTextMessageLength();
            expect(component.classList).not.toContain('hidden');
            expect(component.classList).toContain('text--error');
            expect(submitButton.disabled).toEqual(true);
        });
    });
});
