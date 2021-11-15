import { limitTextMessageLength } from 'lib/text_message_length_limiter';
const fs = require("fs");
const path = require("path");


describe('text message form with length limiter', () => {
    const { body } = document;
    const lorumIpsum = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante i"

    let textarea;
    let counter;
    let component;
    let submitButton;
    const TEMPLATE = fs.readFileSync(path.join(__dirname, "/template.html"));

    beforeEach(() => {
        body.innerHTML = TEMPLATE;
        textarea = body.querySelector("textarea.text-message-body");
        component = body.querySelector(".text-message-length-limiter")
        counter = body.querySelector('[data-target="length-counter"]');
        submitButton = body.querySelector("input[type='submit']");
    });

    test("it sets the current length into the counter on initialization (less than 1600)", () => {
        textarea.value = "123456789"
        limitTextMessageLength();
        expect(counter.innerHTML).toEqual("9")
        expect(counter.classList.length).toEqual(0)
        expect(submitButton.disabled).toEqual(false)

    });

    test("it sets the current length into the counter on initialization (= 1600)", () => {
        textarea.value = lorumIpsum
        limitTextMessageLength();
        expect(counter.innerHTML).toEqual("1600");
        expect(component.classList).toContain('text--error');
        expect(submitButton.disabled).toEqual(true);
    });

    test("it sets the current length into the counter on initialization (= 1605)", () => {
        textarea.value = lorumIpsum + "12345"
        limitTextMessageLength();
        expect(counter.innerHTML).toEqual("1605");
        expect(component.classList).toContain('text--error');
        expect(submitButton.disabled).toEqual(true);
    });

    test("changing the length and triggering an input event (9 -> 1605)", () => {
        textarea.value = "123456789"
        limitTextMessageLength();
        expect(counter.innerHTML).toEqual("9");

        textarea.value = lorumIpsum;
        let event = new Event('input');
        textarea.dispatchEvent(event);
        expect(counter.innerHTML).toEqual("1600");
        expect(component.classList).toContain('text--error');
        expect(submitButton.disabled).toEqual(true);
    });
});
