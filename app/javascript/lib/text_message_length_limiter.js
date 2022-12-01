export function limitTextMessageLength() {
    const textMessageInput = document.querySelector("textarea.text-message-body");
    const component = document.querySelector('.text-message-length-limiter');
    const textMessageFormButton = textMessageInput.form.querySelector("input[type='submit']");
    const messageLengthDisableRadioButton = document.querySelector(".message-length-limiter-disable");

    setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton.checked);
    textMessageInput.addEventListener('input', function() {
        setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton.checked);
    });
    messageLengthDisableRadioButton.closest('radiogroup').addEventListener('change', function() {
        setLengthProperties(textMessageInput.value.length, component, textMessageFormButton, messageLengthDisableRadioButton.checked);
    });
}

function setLengthProperties(length, component, textMessageFormButton, disable) {
    if (disable == true) {
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
