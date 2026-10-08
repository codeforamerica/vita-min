export function limitTextMessageLength() {
    const textMessageInput = document.querySelector("textarea.text-message-body");
    const component = document.querySelector('.text-message-length-limiter');
    const textMessageFormButton = textMessageInput.form.querySelector("input[type='submit']");
    const messageLengthDisableRadioButton = document.querySelector(".message-length-limiter-disable");

    setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton);
    textMessageInput.addEventListener('input', function() {
        setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton);
    });
    if (messageLengthDisableRadioButton != null) {
        // Honeycrisp renders the radio set as <div class="honeycrisp-radiogroup">; older
        // markup used a <radiogroup> element. Fall back to the form so a future markup
        // change can't leave the listener unattached.
        const radioGroup = messageLengthDisableRadioButton.closest('.honeycrisp-radiogroup, radiogroup') ||
            messageLengthDisableRadioButton.form;
        radioGroup.addEventListener('change', function() {
            setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton);
        });
    };
}

function setLengthProperties(length, component, textMessageFormButton, disableRadioButton) {
    if (disableRadioButton != null && disableRadioButton.checked == true) {
        component.classList.add('hidden');
        textMessageFormButton.disabled = false;
    } else {
        component.classList.remove('hidden');
        const lengthElement = component.querySelector('[data-target="length-counter"]');
        const errorMessageElement = component.querySelector('[data-target="error-message"]');
        lengthElement.textContent = length;
        if (length >= 900) {
            component.classList.add('text--error');
            errorMessageElement.classList.remove("hidden");
            textMessageFormButton.disabled = true;
        } else {
            component.classList.remove('text--error');
            errorMessageElement.classList.add("hidden");
            textMessageFormButton.disabled = false;
        }
    }
}
