export function limitTextMessageLength() {
    const textMessageInput = document.querySelector("textarea.text-message-body");
    const component = document.querySelector('.text-message-length-limiter');
    const textMessageFormButton = textMessageInput.form.querySelector("input[type='submit']");

    setLengthProperties(textMessageInput.value.length, component, textMessageFormButton);
    textMessageInput.addEventListener('input', function() {
        setLengthProperties(textMessageInput.value.length, component, textMessageFormButton)
    });
}

function setLengthProperties(length, component, textMessageFormButton) {
    const lengthElement = component.querySelector('[data-target="length-counter"]');
    const errorMessageElement = component.querySelector('[data-target="error-message"]');
    lengthElement.textContent = length;
    if (length >= 1600) {
        component.classList.add('text--error');
        errorMessageElement.classList.remove("hidden");
        textMessageFormButton.disabled = true;
    } else {
        component.classList.remove('text--error');
        errorMessageElement.classList.add("hidden");
        textMessageFormButton.disabled = false;
    }
}
