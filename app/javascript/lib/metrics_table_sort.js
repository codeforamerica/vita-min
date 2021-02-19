import { initSortableColumn } from './table_sort';

// Sum site-level counts into org-level values for org row.
function setupOrgLevelCounts() {
    $(".org-metrics").each(function() {
        let denominator = 0;
        let attention_count = 0;
        let communication_count = 0;
        let interaction_count = 0;

        if ($(this).find('tr.site').length == 0) {
            denominator += parseInt($(this).find('tr.org').first().attr('data-js-count'));
        }

        $(this).find('tr.site').each(function() {
            denominator += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.attention-needed-breach').each(function() {
            attention_count += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.communication-breach').each(function() {
            communication_count += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.interaction-breach').each(function() {
            interaction_count += parseInt($(this).attr('data-js-count'));
        });

        // Set viewable value and sortable data-js-count value for org based on accumulated value.
        $(this).find('.attention-needed-breach').first().text(attention_count).attr('data-js-count', attention_count);
        let attention_percentage, attention_percentage_text;
        [attention_percentage, attention_percentage_text] = determineBreaches(attention_count, denominator);
        $(this).find('.attention-needed-breach-percentage').first().text(attention_percentage_text).attr('data-js-percentage', attention_percentage);

        $(this).find('.communication-breach').first().text(communication_count).attr('data-js-count', communication_count);
        let comm_percentage, comm_percentage_text;
        [comm_percentage, comm_percentage_text] = determineBreaches(communication_count, denominator);
        $(this).find('.communication-breach-percentage').first().text(comm_percentage_text).attr('data-js-percentage', comm_percentage);

        $(this).find('.interaction-breach').first().text(interaction_count).attr('data-js-count', interaction_count);
        let interaction_percentage, interaction_percentage_text;
        [interaction_percentage, interaction_percentage_text] = determineBreaches(interaction_count, denominator);
        $(this).find('.interaction-breach-percentage').first().text(interaction_percentage_text).attr('data-js-percentage', interaction_percentage);

        // Loop through all sites to set breach percentages
        $(this).find('tr.site').each(function() {
            let attention_percentage, attention_percentage_text;
            [attention_percentage, attention_percentage_text] = determineBreaches(parseInt($(this).find('.attention-needed-breach').attr('data-js-count')), parseInt($(this).attr('data-js-count')));
            $(this).find('.attention-needed-breach-percentage').first().text(attention_percentage_text).attr('data-js-percentage', attention_percentage);
            let comm_percentage, comm_percentage_text;
            [comm_percentage, comm_percentage_text] = determineBreaches(parseInt($(this).find('.communication-breach').attr('data-js-count')), parseInt($(this).attr('data-js-count')));
            $(this).find('.communication-breach-percentage').first().text(comm_percentage_text).attr('data-js-percentage', comm_percentage);
            let interaction_percentage, interaction_percentage_text;
            [interaction_percentage, interaction_percentage_text] = determineBreaches(parseInt($(this).find('.interaction-breach').attr('data-js-count')), parseInt($(this).attr('data-js-count')));
            $(this).find('.interaction-breach-percentage').first().text(interaction_percentage_text).attr('data-js-percentage', interaction_percentage);
        });
    });

    let totalSLATracked = $('.metrics-totals').attr('data-js-count');
    let attention_percentage, attention_percentage_text;
    [attention_percentage, attention_percentage_text] = determineBreaches(parseInt($('.metrics-totals').find('.attention-needed-breach').attr('data-js-count')), totalSLATracked);
    $('.metrics-totals').find('.attention-needed-breach-percentage').first().text(attention_percentage_text).attr('data-js-percentage', attention_percentage);
    let comm_percentage, comm_percentage_text;
    [comm_percentage, comm_percentage_text] = determineBreaches(parseInt($('.metrics-totals').find('.communication-breach').attr('data-js-count')), totalSLATracked);
    $('.metrics-totals').find('.communication-breach-percentage').first().text(comm_percentage_text).attr('data-js-percentage', comm_percentage);
    let interaction_percentage, interaction_percentage_text;
    [interaction_percentage, interaction_percentage_text] = determineBreaches(parseInt($('.metrics-totals').find('.interaction-breach').attr('data-js-count')), totalSLATracked);
    $('.metrics-totals').find('.interaction-breach-percentage').first().text(interaction_percentage_text).attr('data-js-percentage', interaction_percentage);
}

function determineBreaches(breachCount, totalCount) {
    let percentage = isNaN(breachCount/totalCount) ? 0 : (breachCount/totalCount * 100).toFixed(2).replace(/[.,]00$/, "");
    let text = `${breachCount}/${totalCount} (${percentage}%)`;
    return [percentage, text];
}

// Use attribute data-js-count to determine whether a row or set of rows includes any breaches.
function setupBreachDataClasses() {
    $(".site, .org").each(function() {
        let values = [];

        $(this).children('td').each(function() {
            values.push($(this).attr('data-js-count'));
        });

        const noBreaches = values.filter(function(v) { return v != undefined; }).every(function(v) { return v == 0 });
        if (noBreaches) {
            $(this).addClass('no-breaches');
        } else {
            $(this).addClass('with-breaches');
        }
    });
}

// Logic for expanding/collapsing sites
function initToggleableSites() {
    $('button#toggle-sites').click(function() {
        $(this).toggleClass('button--inverted');

        if (!$(this).attr('data-collapse')) {
            $(".site").each(function() {
                $(this).hide();
            });
            $(this).attr('data-collapse', true)
            $(this).text($(this).attr('data-expand-text'));
        } else {
            let elements = ".site";
            if ($("button#toggle-zeros").attr('data-collapse')) {
                elements += ".with-breaches"
            }
            $(elements).each(function() {
                $(this).show();
            });
            $(this).text($(this).attr('data-collapse-text'));
            $(this).removeAttr('data-collapse');
        }
    });
}

// Logic for collapsing/expanding orgs + sites that have 0 breaches.
function initToggleableZeroValues() {
    $("button#toggle-zeros").click(function() {
        $(this).toggleClass('button--inverted');
        if (!$(this).attr('data-collapse')) {
            let elements = ".org";
            if (!$("button#toggle-sites").attr('data-collapse')) {
                elements += ", .site"
            }
            $(elements).each(function () {
                if ($(this).hasClass('no-breaches')) {
                    $(this).hide();
                }
            });

            $(this).attr('data-collapse', true)
            $(this).text($(this).attr('data-expand-text'));
        } else {
            let elements = ".org.no-breaches"
            if (!$("button#toggle-sites").attr('data-collapse')) {
                elements += ", .site.no-breaches"
            }
            $(elements).each(function() {
                $(this).show();
            });
            $(this).text($(this).attr('data-collapse-text'));
            $(this).removeAttr('data-collapse');
        }
    });
}

export function initMetricsTableSortAndFilter() {
    setupOrgLevelCounts();
    setupBreachDataClasses();

    initToggleableSites();
    initToggleableZeroValues();

    initSortableColumn("tbody.org-metrics", "th#outgoing-communication-breaches", function(row) {
        const calc = parseInt($(row).find('.communication-breach').attr('data-js-count'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#profile-interaction-breaches", function(row) {
        const calc = parseInt($(row).find('.interaction-breach').attr('data-js-count'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#needs-attention-breaches", function(row) {
        const calc = parseInt($(row).find('.attention-needed-breach').attr('data-js-count'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#organization-name", function (row) {
        return $(row).attr('data-js-vita-partner-name');
    });

    initSortableColumn("tbody.org-metrics", "th#needs-attention-percentage", function (row) {
        const calc = parseInt($(row).find('.attention-needed-breach-percentage').attr('data-js-percentage'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#outgoing-communication-percentage", function (row) {
        const calc = parseInt($(row).find('.communication-breach-percentage').attr('data-js-percentage'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#profile-interaction-percentage", function (row) {
        const calc = parseInt($(row).find('.interaction-breach-percentage').attr('data-js-percentage'));
        return isNaN(calc) ? 0 : calc;
    });
}