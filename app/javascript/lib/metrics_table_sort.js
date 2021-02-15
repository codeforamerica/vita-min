import { initSortableColumn } from './table_sort';

// Sum site-level counts into org-level values for org row.
function setupOrgLevelCounts() {
    $(".org-metrics").each(function() {
        let attention_count = 0;
        let communication_count = 0;
        let interaction_count = 0;
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
        if (attention_count > 0) {
            $(this).find('.attention-needed-breach').first().text(attention_count).attr('data-js-count', attention_count);
        }
        if (communication_count > 0) {
            $(this).find('.communication-breach').first().text(communication_count).attr('data-js-count', communication_count);
        }
        if (interaction_count > 0) {
            $(this).find('.interaction-breach').first().text(interaction_count).attr('data-js-count', interaction_count);
        }
    });
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
    $('button.toggle-sites').click(function() {
        if (!$(this).attr('data-collapse')) {
            $(".site").each(function() {
                $(this).hide();
            });
            $(this).attr('data-collapse', true)
            $(this).text($(this).attr('data-expand-text'));
        } else {
            let elements = ".site";
            if ($("button.toggle-zeros").attr('data-collapse')) {
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
    $("button.toggle-zeros").click(function() {
        console.log("clicked")
        if (!$(this).attr('data-collapse')) {
            let elements = ".org";
            debugger
            if (!$("button.toggle-sites").attr('data-collapse')) {
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
            if (!$("button.toggle-sites").attr('data-collapse')) {
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
        return $(row).find('.communication-org').attr('data-js-count');
    });

    initSortableColumn("tbody.org-metrics", "th#profile-interaction-breaches", function(row) {
        return $(row).find('.interaction-org').attr('data-js-count');
    });

    initSortableColumn("tbody.org-metrics", "th#needs-attention-breaches", function(row) {
        return $(row).find('.attention-needed-org').attr('data-js-count');
    });

    initSortableColumn("tbody.org-metrics", "th#organization-name", function (row) {
        return $(row).attr('data-js-vita-partner-name');
    });
}