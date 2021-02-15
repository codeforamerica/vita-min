import { initMetricsTableSortAndFilter } from 'lib/metrics_table_sort';


beforeAll(() => {
    document.body.innerHTML = `
    <button class="toggle-zeros" data-expand-text="Expand" data-collapse-text="Collapse"></button>
    <button class="toggle-sites" data-expand-text="Expand" data-collapse-text="Collapse"></button>
    <table>
        <thead>
            <th id="organization-name"></th>
            <th id="profile-interaction-breaches"></th>
            <th id="needs-attention-breaches"></th>
            <th id="outgoing-communication-breaches"></th>
        </thead>
        <tbody class="org-metrics" data-js-vita-partner-name="Orange Org">
            <tr class="org">
                <td class="attention-needed-breach" data-js-count="hi"></td>
                <td class="communication-breach" data-js-count="placeholder"></td>
                <td class="interaction-breach" data-js-count="to-replace"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="3"></td>
                <td class="communication-breach" data-js-count="1"></td>
                <td class="interaction-breach" data-js-count="3"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="0"></td>
                <td class="communication-breach" data-js-count="0"></td>
                <td class="interaction-breach" data-js-count="1"></td>
            </tr>
        </tbody>
        <tbody class="org-metrics" data-js-vita-partner-name="Orange Org">
            <tr class="org">
                <td class="attention-needed-breach"></td>
                <td class="communication-breach"></td>
                <td class="interaction-breach"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="5"></td>
                <td class="communication-breach" data-js-count="5"></td>
                <td class="interaction-breach" data-js-count="5"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="1"></td>
                <td class="communication-breach" data-js-count="1"></td>
                <td class="interaction-breach" data-js-count="1"></td>
            </tr>
        </tbody>
        <tbody class="org-metrics" data-js-vita-partner-name="Perfect Org">
            <tr class="org">
                <td class="attention-needed-breach"></td>
                <td class="communication-breach"></td>
                <td class="interaction-breach"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="0"></td>
                <td class="communication-breach" data-js-count="0"></td>
                <td class="interaction-breach" data-js-count="0"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="0"></td>
                <td class="communication-breach" data-js-count="0"></td>
                <td class="interaction-breach" data-js-count="0"></td>
            </tr>
        </tbody>
    </table>
    `
});

test('determines org-level counts', () => {
    const attentionBreach = $('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.org td.attention-needed-breach').first();
    const communicationBreach = $('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.org td.communication-breach').first();
    const interactionBreach =$('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.org td.interaction-breach').first();
    expect(attentionBreach.attr('data-js-count')).toEqual("hi");
    expect(communicationBreach.attr('data-js-count')).toEqual('placeholder');
    expect(interactionBreach.attr('data-js-count')).toEqual('to-replace');

    initMetricsTableSortAndFilter();

    expect(attentionBreach.attr('data-js-count')).toEqual("3");
    expect(communicationBreach.attr('data-js-count')).toEqual("1");
    expect(interactionBreach.attr('data-js-count')).toEqual("4");
});

test('adds breach classes to each row', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();
    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();
    const orangeOrg = $('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.org').first();

    expect(perfectOrg.hasClass('no-breaches')).toEqual(false);
    expect(perfectSite.hasClass('no-breaches')).toEqual(false);

    expect(orangeOrg.hasClass('with-breaches')).toEqual(false)

    initMetricsTableSortAndFilter();

    expect(perfectOrg.hasClass('no-breaches')).toEqual(true);
    expect(perfectSite.hasClass('no-breaches')).toEqual(true);
    expect(orangeOrg.hasClass('with-breaches')).toEqual(true);
});

test('collapses & expands 0-count orgs/sites', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();
    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();

    initMetricsTableSortAndFilter();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');

    expect($('button.toggle-zeros').text()).toEqual('Expand');
    $('button.toggle-zeros').click();
    expect($('button.toggle-zeros').text()).toEqual('Collapse');

    expect(perfectOrg.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');

    $('button.toggle-zeros').click();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});

test('collapses & expands sites', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();

    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();

    initMetricsTableSortAndFilter();

    $('button.toggle-sites').click();

    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('none');

    expect($('button.toggle-sites').text()).toEqual('Expand');
    $('button.toggle-sites').click();
    expect($('button.toggle-sites').text()).toEqual('Collapse');

    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});

test("collapse and expand sites and zeros simultaneously", () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();

    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();
    const orangeOrg = $('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.org').first();
    const orangeSite = $('.org-metrics[data-js-vita-partner-name="Orange Org"]').find('tr.site').first();
    initMetricsTableSortAndFilter();

    // collapses zeros
    $('button.toggle-zeros').click();

    expect(perfectOrg.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');
    expect(orangeOrg.css('display')).toEqual('table-row');
    expect(orangeSite.css('display')).toEqual('table-row');

    // collapses sites
    $('button.toggle-sites').click();

    expect(orangeSite.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');

    // expands org non-zeros, but keeps all sites closed
    $('button.toggle-zeros').click();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('none');
    expect(orangeOrg.css('display')).toEqual('table-row');
    expect(orangeSite.css('display')).toEqual('none');

    // expands sites
    $('button.toggle-sites').click();
    expect(orangeSite.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});