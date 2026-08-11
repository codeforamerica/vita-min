// The service comparison cards used CSS subgrid to line up their sections (see the @supports block
// in stylesheets/components/_service-card.scss). That aligns them beautifully, but a subgrid item's
// height is derived from the parent's row tracks, so all four cards are necessarily the same height
// and cannot be sized independently -- an expanding reveal grew every card, and an explicit height
// on the closed ones is silently ignored.
//
// This replaces that mechanism: the cards become ordinary flex columns, and the sections above the
// reveal are given a shared height here. Every reveal trigger still starts at the same y position,
// but each card is now free to grow on its own, so opening one reveal expands only that card.
//
// Without JavaScript the subgrid rules still apply, so the cards stay aligned and simply share
// height as before.

const ROW_SELECTOR = ".service-recommendation";
const CARD_SELECTOR = ".service-card";
const ALIGNED_CLASS = "is-js-aligned";

const SECTION_SELECTORS = [
  ".service-card--title",
  ".service-card--body",
  ".button-wrapper",
  ".service-card--list",
];

function sideBySide(cards) {
  const first = cards[0].getBoundingClientRect().top;
  return cards.every((card) => Math.abs(card.getBoundingClientRect().top - first) < 1);
}

function initServiceCardAlignment() {
  document.querySelectorAll(ROW_SELECTOR).forEach((row) => {
    const cards = Array.from(row.querySelectorAll(CARD_SELECTOR));
    // A lone recommendation card has nothing to line up with.
    if (cards.length < 2) return;

    const sectionsFor = (selector) =>
      cards.map((card) => card.querySelector(selector)).filter(Boolean);

    const clear = () => {
      SECTION_SELECTORS.forEach((selector) => {
        sectionsFor(selector).forEach((section) => { section.style.minHeight = ""; });
      });
    };

    const align = () => {
      clear();

      if (!sideBySide(cards)) {
        row.classList.remove(ALIGNED_CLASS);
        return;
      }

      row.classList.add(ALIGNED_CLASS);

      SECTION_SELECTORS.forEach((selector) => {
        const sections = sectionsFor(selector);
        if (sections.length !== cards.length) return;

        const tallest = Math.max(...sections.map((s) => s.getBoundingClientRect().height));
        sections.forEach((section) => { section.style.minHeight = `${tallest}px`; });
      });
    };

    align();

    let resizeTimer;
    window.addEventListener("resize", () => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(align, 150);
    });

    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(align);
    }
  });
}

export { initServiceCardAlignment };
