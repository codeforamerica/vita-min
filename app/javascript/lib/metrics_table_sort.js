import { initSortableColumn } from './table_sort';

// Sum site-level counts into org-level values for org row.
function setupOrgLevelCounts() {
    let totalCapacityCount = 0;
    let totalActiveCount = 0;
    $(".org-metrics").each(function() {
        let denominator = 0;
        let unansweredCommunicationCount = 0;
        const capacityCount = parseInt($(this).find('tr.org').first().attr('data-js-capacity'));
        const activeClientCount = parseInt($(this).find('tr.org td.capacity-percentage').first().attr('data-js-count'));
        totalCapacityCount += capacityCount;
        totalActiveCount += activeClientCount;
        if ($(this).find('tr.site').length == 0) {
            denominator = parseInt($(this).find('tr.org').first().attr('data-js-count'));
            unansweredCommunicationCount = parseInt($(this).find('tr.org td.unanswered-communication-breach').first().attr('data-js-count'));
        }

        $(this).find('tr.site').each(function() {
            denominator += parseInt($(this).attr('data-js-count'));
        });

        $(this).find('tr.site td.unanswered-communication-breach').each(function() {
            unansweredCommunicationCount += parseInt($(this).attr('data-js-count'));
        });

        // Set viewable value and sortable data-js-count value for org based on accumulated value.
        $(this).find('.unanswered-communication-breach').first().text(unansweredCommunicationCount).attr('data-js-count', unansweredCommunicationCount);

        updatePercentages(this, '.unanswered-communication-breach', denominator);
        updatePercentages(this, '.capacity', capacityCount);

        // // Loop through all sites to set breach percentages
        $(this).find('tr.site').each(function() {
            const siteDenominator = parseInt($(this).attr('data-js-count'))
            updatePercentages(this, '.unanswered-communication-breach', siteDenominator);
        });
    });
    let totalSLATracked = $('.metrics-totals').attr('data-js-count');
    updatePercentages('.metrics-totals', '.unanswered-communication-breach', totalSLATracked);
    $(".metrics-totals").find(".capacity").attr('data-js-count', totalActiveCount);
    updatePercentages('.metrics-totals', '.capacity', totalCapacityCount)
}

function updatePercentages(sectionSelector, breachTypeSelector, denominator) {
    let percentageSelector = breachTypeSelector + "-percentage";
    let percentage, percentageText;
    [percentage, percentageText] = determineBreachPercentages($(sectionSelector).find(breachTypeSelector).attr('data-js-count'), denominator);
    $(sectionSelector).find(percentageSelector).first().text(percentageText).attr('data-js-percentage', percentage);
}

function determineBreachPercentages(breachCount, totalCount) {
    let value = breachCount/totalCount;
    let percentage = isNaN(value) ? 0 : (breachCount/totalCount * 100).toFixed(2).replace(/[.,]00$/, "");
    percentage = !isFinite(value) ? "-1" : percentage;
    let text = isFinite(value) ? `${breachCount}/${totalCount} (${percentage}%)` : `${breachCount}/${totalCount}`;
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

    initSortableColumn("tbody.org-metrics", "th#unanswered-communication-breaches", function(row) {
        const calc = parseInt($(row).find('.unanswered-communication-breach').attr('data-js-count'));
        return isNaN(calc) ? 0 : calc;
    });

    initSortableColumn("tbody.org-metrics", "th#organization-name", function (row) {
        return $(row).attr('data-js-vita-partner-name');
    });

    initSortableColumn("tbody.org-metrics", "th#unanswered-communication-percentage", function (row) {
        const calc = parseInt($(row).find('.unanswered-communication-breach-percentage').attr('data-js-percentage'));
        return isNaN(calc) ? 0 : calc;
    });


    initSortableColumn("tbody.org-metrics", "th#capacity-percentage", function (row) {
        const calc = parseInt($(row).find('.capacity-percentage').attr('data-js-percentage'));
        return isNaN(calc) ? 0 : calc;
    });
}