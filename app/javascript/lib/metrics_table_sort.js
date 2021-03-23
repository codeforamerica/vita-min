import { initSortableColumn } from './table_sort';

// Sum site-level counts into org-level values for org row.
function setupOrgLevelCounts() {
    $(".org-metrics").each(function() {
        let denominator = 0;
        let responseCount = 0;
        let communicationCount = 0;
        let interactionCount = 0;

        if ($(this).find('tr.site').length == 0) {
            denominator = parseInt($(this).find('tr.org').first().attr('data-js-count'));
            responseCount = parseInt($(this).find('tr.org td.response-needed-breach').first().attr('data-js-count'));
            communicationCount = parseInt($(this).find('tr.org td.communication-breach').first().attr('data-js-count'));
            interactionCount = parseInt($(this).find('tr.org td.interaction-breach').first().attr('data-js-count'));
        }

        $(this).find('tr.site').each(function() {
            denominator += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.response-needed-breach').each(function() {
            responseCount += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.communication-breach').each(function() {
            communicationCount += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.interaction-breach').each(function() {
            interactionCount += parseInt($(this).attr('data-js-count'));
        });

        // Set viewable value and sortable data-js-count value for org based on accumulated value.
        $(this).find('.response-needed-breach').first().text(responseCount).attr('data-js-count', responseCount);
        $(this).find('.communication-breach').first().text(communicationCount).attr('data-js-count', communicationCount);
        $(this).find('.interaction-breach').first().text(interactionCount).attr('data-js-count', interactionCount);
        updatePercentages(this, '.response-needed-breach', denominator);
        updatePercentages(this, '.communication-breach', denominator);
        updatePercentages(this, '.interaction-breach', denominator);

        // // Loop through all sites to set breach percentages
        $(this).find('tr.site').each(function() {
            const siteDenominator = parseInt($(this).attr('data-js-count'))
            updatePercentages(this, '.response-needed-breach', siteDenominator);
            updatePercentages(this, '.communication-breach', siteDenominator);
            updatePercentages(this, '.interaction-breach', siteDenominator);
        });
    });
    let totalSLATracked = $('.metrics-totals').attr('data-js-count');
    updatePercentages('.metrics-totals', '.response-needed-breach', totalSLATracked);
    updatePercentages('.metrics-totals', '.communication-breach', totalSLATracked);
    updatePercentages('.metrics-totals', '.interaction-breach', totalSLATracked);
}

function updatePercentages(sectionSelector, breachTypeSelector, denominator) {
    let percentageSelector = breachTypeSelector + "-percentage";
    let percentage, percentageText;
    [percentage, percentageText] = determineBreachPercentages($(sectionSelector).find(breachTypeSelector).attr('data-js-count'), denominator);
    $(sectionSelector).find(percentageSelector).first().text(percentageText).attr('data-js-percentage', percentage);
}

function determineBreachPercentages(breachCount, totalCount) {
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

    initSortableColumn("tbody.org-metrics", "th#needs-response-breaches", function(row) {
        const calc = parseInt($(row).find('.response-needed-breach').attr('data-js-count'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#organization-name", function (row) {
        return $(row).attr('data-js-vita-partner-name');
    });

    initSortableColumn("tbody.org-metrics", "th#needs-response-percentage", function (row) {
        const calc = parseInt($(row).find('.response-needed-breach-percentage').attr('data-js-percentage'));
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