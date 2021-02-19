import { initMetricsTableSortAndFilter } from 'lib/metrics_table_sort';

beforeEach(() => {
  document.body.innerHTML = `
    <button id="toggle-zeros" data-expand-text="Expand" data-collapse-text="Collapse"></button>
    <button id="toggle-sites" data-expand-text="Expand" data-collapse-text="Collapse"></button>
    <table>
        <thead>
            <th id="organization-name"></th>
            <th id="needs-attention-breaches"></th>
            <th id="profile-interaction-breaches"></th>
            <th id="outgoing-communication-breaches"></th>
        </thead>
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
        <tbody class="index-table__body org-metrics" data-js-vita-partner-name="United Way of Greater Richmond and Petersburg">
          <tr class="index-table__row org">
            <td class="index-table__cell">United Way of Greater Richmond and Petersburg</td>
            <td class="index-table__cell attention-needed-breach"  data-js-count=1>
              1
            </td>
            <td class="index-table__cell communication-breach" data-js-count=3>
              3
            </td>
            <td class="index-table__cell interaction-breach" data-js-count=1>
              1
            </td>
          </tr>
          <!-- Add a row for the organization to track org-level breaches. -->
          <tr class="index-table__row site">
            <td class="index-table__cell" style="padding-left: 60px; font-style: italic;">United Way of Greater Richmond and Petersburg</td>
            <td class="index-table__cell attention-needed-breach"  data-js-count=1>
              1
            </td>
            <td class="index-table__cell communication-breach" data-js-count=3>
              3
            </td>
            <td class="index-table__cell interaction-breach" data-js-count=1>
              1
            </td>
          </tr>

          <tr class="index-table__row site">
            <td class="index-table__cell" style="padding-left: 60px">Chesterfield Meadowdale Library </td>
            <td class="index-table__cell attention-needed-breach" data-js-count=0>
              0
            </td>
            <td class="index-table__cell communication-breach" data-js-count=0>
              0
            </td>
            <td class="index-table__cell interaction-breach" data-js-count=0>
              0
            </td>
          </tr>
          <tr class="index-table__row site">
            <td class="index-table__cell" style="padding-left: 60px">Libbie Mill Library </td>
            <td class="index-table__cell attention-needed-breach" data-js-count=1>
              1
            </td>
            <td class="index-table__cell communication-breach" data-js-count=0>
              0
            </td>
            <td class="index-table__cell interaction-breach" data-js-count=0>
              0
            </td>
          </tr>
            <tr class="index-table__row site">
              <td class="index-table__cell" style="padding-left: 60px">Fairfield Library - UWGRP </td>
              <td class="index-table__cell attention-needed-breach" data-js-count=1>
                1
              </td>
              <td class="index-table__cell communication-breach" data-js-count=1>
                1
              </td>
              <td class="index-table__cell interaction-breach" data-js-count=1>
                1
              </td>
            </tr>
            <tr class="index-table__row site">
              <td class="index-table__cell" style="padding-left: 60px">Neighborhood Resource Center </td>
              <td class="index-table__cell attention-needed-breach" data-js-count=0>
                0
              </td>
              <td class="index-table__cell communication-breach" data-js-count=0>
                0
              </td>
              <td class="index-table__cell interaction-breach" data-js-count=0>
                0
              </td>
            </tr>
            <tr class="index-table__row site">
              <td class="index-table__cell" style="padding-left: 60px">UWGRP-site </td>
              <td class="index-table__cell attention-needed-breach" data-js-count=0>
                0
              </td>
              <td class="index-table__cell communication-breach" data-js-count=3>
                3
              </td>
              <td class="index-table__cell interaction-breach" data-js-count=3>
                3
              </td>
            </tr>
        </tbody>
        <tbody class="org-metrics" data-js-vita-partner-name="Apple Org">
            <tr class="org">
                <td class="attention-needed-breach"></td>
                <td class="communication-breach"></td>
                <td class="interaction-breach"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="15"></td>
                <td class="communication-breach" data-js-count="15"></td>
                <td class="interaction-breach" data-js-count="15"></td>
            </tr>
            <tr class="site">
                <td class="attention-needed-breach" data-js-count="1"></td>
                <td class="communication-breach" data-js-count="1"></td>
                <td class="interaction-breach" data-js-count="1"></td>
            </tr>
        </tbody>
    </table>
  `
});

test('determines org-level counts', () => {
    const attentionBreach = $('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.org td.attention-needed-breach').first();
    const communicationBreach = $('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.org td.communication-breach').first();
    const interactionBreach =$('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.org td.interaction-breach').first();
    expect(attentionBreach.attr('data-js-count')).toEqual("1");
    expect(communicationBreach.attr('data-js-count')).toEqual('3');
    expect(interactionBreach.attr('data-js-count')).toEqual('1');

    initMetricsTableSortAndFilter();

    expect(attentionBreach.attr('data-js-count')).toEqual("3");
    expect(communicationBreach.attr('data-js-count')).toEqual("7");
    expect(interactionBreach.attr('data-js-count')).toEqual("5");
});

test('adds breach classes to each row', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();
    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();
    const unitedWayOrg = $('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.org').first();

    expect(perfectOrg.hasClass('no-breaches')).toEqual(false);
    expect(perfectSite.hasClass('no-breaches')).toEqual(false);

    expect(unitedWayOrg.hasClass('with-breaches')).toEqual(false)

    initMetricsTableSortAndFilter();

    expect(perfectOrg.hasClass('no-breaches')).toEqual(true);
    expect(perfectSite.hasClass('no-breaches')).toEqual(true);
    expect(unitedWayOrg.hasClass('with-breaches')).toEqual(true);
});

test('collapses & expands 0-count orgs/sites', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();
    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();

    initMetricsTableSortAndFilter();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');

    $('button#toggle-zeros').click();

    expect(perfectOrg.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');

    $('button#toggle-zeros').click();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});

test('collapses & expands sites', () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();

    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();

    initMetricsTableSortAndFilter();

    $('button#toggle-sites').click();

    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('none');

    $('button#toggle-sites').click();

    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});

test("collapse and expand sites and zeros simultaneously", () => {
    const perfectOrg = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.org').first();

    const perfectSite = $('.org-metrics[data-js-vita-partner-name="Perfect Org"]').find('tr.site').first();
    const unitedWayOrg = $('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.org').first();
    const unitedWaySite = $('.org-metrics[data-js-vita-partner-name="United Way of Greater Richmond and Petersburg"]').find('tr.site').first();
    initMetricsTableSortAndFilter();

    // collapses zeros
    $('button#toggle-zeros').click();

    expect(perfectOrg.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');
    expect(unitedWayOrg.css('display')).toEqual('table-row');
    expect(unitedWaySite.css('display')).toEqual('table-row');

    // collapses sites
    $('button#toggle-sites').click();

    expect(unitedWaySite.css('display')).toEqual('none');
    expect(perfectSite.css('display')).toEqual('none');

    // expands org non-zeros, but keeps all sites closed
    $('button#toggle-zeros').click();
    expect(perfectOrg.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('none');
    expect(unitedWayOrg.css('display')).toEqual('table-row');
    expect(unitedWaySite.css('display')).toEqual('none');

    // expands sites
    $('button#toggle-sites').click();
    expect(unitedWaySite.css('display')).toEqual('table-row');
    expect(perfectSite.css('display')).toEqual('table-row');
});

test('sorting by name', () => {
    expect($('.org-metrics').first().attr('data-js-vita-partner-name')).toEqual("Perfect Org");
    initMetricsTableSortAndFilter();
    $('th#organization-name').click();
    expect($('.org-metrics').first().attr('data-js-vita-partner-name')).toEqual("Apple Org");
    $('th#organization-name').click();
    expect($('.org-metrics').first().attr('data-js-vita-partner-name')).toEqual("United Way of Greater Richmond and Petersburg");
});



