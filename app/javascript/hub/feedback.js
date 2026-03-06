export default function feedback() {
    document.querySelectorAll('[data-feedback-x]').forEach(button => {
        button.addEventListener('click', () => {
            const notesDiv = document.querySelector('[data-feedback-notes]')
            notesDiv.classList.remove('hidden')
        })
    })
}