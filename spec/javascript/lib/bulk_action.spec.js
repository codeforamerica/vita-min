import {initBulkAction} from 'lib/bulk_action';

describe('bulk action', () => {
    beforeEach(() => {
        // ⚠️ This HTML structure was copy/pasted!!! Might result in flaky test
        document.body.innerHTML = `
            <label class="checkbox--gyr">
                <input id="bulk-edit-select-all" type="checkbox" name="add-all">
                <span>Add all</span>
            </label>
            <input type="checkbox" value="1" name="tr_ids[]" id="tr_ids_1" form="take-action-form">
            <input type="checkbox" value="2" name="tr_ids[]" id="tr_ids_2" form="take-action-form">
            <input type="checkbox" value="3" name="tr_ids[]" id="tr_ids_3" form="take-action-form">
            <footer class="" id="take-action-footer" style="display: none;">
                <span>You have selected <span id="take-action-count">0</span> return(s)</span>
                <form id="take-action-form" action="/en/hub/client-selections/new" accept-charset="UTF-8" method="get">
                    <input type="submit" name="commit" value="Take action" class="button button--primary">
                </form>
            </footer>
        `;
    });


    describe('select all', () => {
        test('checks and unchecks boxes when select all is toggled', () => {
            initBulkAction();
            const selectAllEl = document.querySelector('#bulk-edit-select-all');

            expect(selectAllEl.checked).toEqual(false);

            selectAllEl.click();

            expect(selectAllEl.checked).toEqual(true);
            let allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")].map((box) => box.checked);
            expect(allCheckboxEls).toEqual([true, true, true]);

            selectAllEl.click();

            expect(selectAllEl.checked).toEqual(false);
            allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")].map((box) => box.checked);
            expect(allCheckboxEls).toEqual([false, false, false]);
        });

    });

    describe('take action', () => {
        test('hide and show footer based on selection', () => {
            initBulkAction();
            const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
            const takeActionFooterEl = document.querySelector('#take-action-footer');

            expect(takeActionFooterEl.style).toHaveProperty(
                'display',
                'none',
            );

            allCheckboxEls[0].click();

            expect(takeActionFooterEl.style).not.toHaveProperty(
                'display',
                'none',
            );
        });

        test('footer shows count of single selected element', () => {
            initBulkAction();
            const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
            const takeActionFooterEl = document.querySelector('#take-action-footer');

            allCheckboxEls[0].click();

            expect(takeActionFooterEl.querySelector('span').textContent).toContain("You have selected 1 return(s)");
        });

        test('footer shows count of multiple selected elements', () => {
            initBulkAction();
            const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
            const takeActionFooterEl = document.querySelector('#take-action-footer');

            allCheckboxEls[0].click();
            allCheckboxEls[1].click();

            expect(takeActionFooterEl.querySelector('span').textContent).toContain("You have selected 2 return(s)");
        });


        test('footer shows count of all selected elements', () => {
            initBulkAction();
            const allCheckboxEls = [...document.querySelectorAll("[id^='tr_ids_']")];
            const takeActionFooterEl = document.querySelector('#take-action-footer');
            const selectAllEl = document.querySelector('#bulk-edit-select-all');

            selectAllEl.click();

            expect(takeActionFooterEl.querySelector('span').textContent).toContain("You have selected 3 return(s)");
        });
    });
});