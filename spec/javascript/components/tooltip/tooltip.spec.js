const tooltip = require("../../../../app/javascript/components/tooltip");
const fs = require("fs");
const path = require("path");

const TEMPLATE = fs.readFileSync(path.join(__dirname, "/template.html"));

describe("tooltip", () => {
  const { body } = document;
  let tooltipBody;
  let tooltipTrigger

  beforeEach(() => {
    body.innerHTML = TEMPLATE;
    tooltip.init();
    tooltipBody = body.querySelector(".tooltip__body");
    tooltipTrigger = body.querySelector(".tooltip__trigger")
  });

  afterEach(() => {
    body.textContent = '';
  });

  it('trigger is created', () => {
    expect(tooltipTrigger.getAttribute("class")).toEqual("button tooltip__trigger");
  });

  it('title attribute on trigger is cleared', () => {
    expect(tooltipTrigger.getAttribute("title")).toEqual("");
  });

  it('tooltip body is created', () => {
    expect(tooltipBody.innerHTML).toEqual("This is a tooltip");
  });

  it('tooltip is visible on focus', () => {
    tooltipTrigger.focus();
    expect(tooltipBody.classList.contains("is-set")).toEqual(true);
  });

  it('tooltip is hidden on blur', () => {
    tooltipTrigger.blur();
    expect(tooltipBody.classList.contains("is-set")).toEqual(false);
  });
})
