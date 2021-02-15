import { initSortableColumn } from 'lib/table_sort';
beforeEach(() => {
    document.body.innerHTML = `
        <table class="one-direction-table">
            <thead>
                <th id="name">Name</th>
                <th id="age">Age</th>
            </thead>
            <tbody>
                <tr class="member">
                    <td class="name">Niall</td>
                    <td data-age="26">26</td>
                </tr>
                <tr class="member">
                    <td class="name">Zayn</td>
                    <td data-age="28">28</td>
                </tr>
                <tr class="member">
                    <td class="name">Harry</td>
                    <td data-age="27">27</td>
                </tr>
                <tr class="member">
                    <td class="name">Liam</td>
                    <td data-age="27">27</td>

                </tr>
                <tr class="member">
                    <td class="name">Louis</td>
                    <td data-age="29">29</td>
                </tr>
            </tbody>
        </table>
    `;
});

test('sorts rows asc and desc', () => {
    expect($('tr td.name').first().text()).toEqual("Niall");

    initSortableColumn("tr.member", "th#name", function(row) {
        return $(row).find('td.name').first().text();
    });

    $("th#name")[0].click();

    expect($('tr td.name').first().text()).toEqual("Harry");

    $("th#name")[0].click();

    expect($('tr td.name').first().text()).toEqual("Zayn");
});

test('sorts by multiple rows', () => {
    expect($('tr td').first().text()).toEqual("Niall");

    initSortableColumn("tr.member", "th#name", function(row) {
        return $(row).find('td').first().text();
    });
    initSortableColumn("tr.member", "th#age", function(row) {
        return $(row).find('td').last().attr('data-age');
    });

    $("th#name")[0].click();

    expect($('tr td.name').first().text()).toEqual("Harry");

    $("th#name")[0].click();

    expect($('tr td.name').first().text()).toEqual("Zayn");

    $("th#age")[0].click();

    expect($('tr td.name').last().text()).toEqual("Louis");
    expect($('tr td.name').first().text()).toEqual("Niall");
});