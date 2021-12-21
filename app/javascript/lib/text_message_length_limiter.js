export function limitTextMessageLength() {
    const textMessageInput = document.querySelector("textarea.text-message-body");
    const lengthSelector = document.querySelector("#text-message-length-counter");
    const textMessageFormButton = textMessageInput.form.querySelector("input[type='submit']");

    setLengthProperties(textMessageInput.value.length, lengthSelector, textMessageFormButton)
    textMessageInput.addEventListener('input', function() {
        setLengthProperties(this.value.length, lengthSelector, textMessageFormButton)
    });
}

function setLengthProperties(length, lengthSelector, textMessageFormButton) {
    lengthSelector.innerHTML = `${length} / 1600`;
    if (length >= 1600) {
        lengthSelector.classList.add('text--error');
        textMessageFormButton.disabled = true;
    } else {
        lengthSelector.classList.remove('text--error');
        textMessageFormButton.disabled = false;
    }
}