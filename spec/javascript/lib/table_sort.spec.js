import { initSortableColumn } from 'lib/table_sort';
beforeAll(() => {
    document.body.innerHTML = `
        <table class="one-direction-table">
            <thead>
                <th id="name">Name</th>
                <th id="age">Age</th>
            </thead>
            <tbody>
                <tr class="member">
                    <td>Niall</td>
                    <td data-age="26">26</td>
                </tr>
                <tr class="member">
                    <td>Zayn</td>
                    <td data-age="28">28</td>
                </tr>
                <tr class="member">
                    <td>Harry</td>
                    <td data-age="27">27</td>
                </tr>
                <tr class="member">
                    <td>Liam</td>
                    <td data-age="27">27</td>

                </tr>
                <tr class="member">
                    <td>Louis</td>
                    <td data-age="29">29</td>
                </tr>
            </tbody>
        </table>
    `;
});

test('sorts rows asc and desc', () => {
    expect($('tr td').first().text()).toEqual("Niall");

    initSortableColumn("tr.member", "th#name", function(row) {
        return $(row).find('td').first().text();
    });

    $("th#name")[0].click();

    expect($('tr td').first().text()).toEqual("Harry");

    $("th#name")[0].click();

    expect($('tr td').first().text()).toEqual("Zayn");
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

    expect($('tr td').first().text()).toEqual("Harry");

    $("th#name")[0].click();

    expect($('tr td').first().text()).toEqual("Zayn");

    expect($('tr td')[3].text()).toEqual("Louis");

    $("th#age")[0].click();

    expect($('tr td').last().text()).toEqual("Louis");
    expect($('tr td').first().text()).toEqual("Niall");
});