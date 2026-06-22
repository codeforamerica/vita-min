export default function feedback() {
    // reveals feedback notes box when incorrect (x) is selected
    document.querySelectorAll('[data-feedback-x]').forEach(button => {
        button.addEventListener('click', () => {
            const notesDiv = document.querySelector('[data-feedback-notes]')
            notesDiv.classList.remove('hidden')
        })
    })
}