function sort(rowSelector, direction, sortableParamCallback) {
    let stillSwitching = true;

    while (stillSwitching) {
        let i;
        stillSwitching = false;
        let willSwitch = false;
        let rows = $(rowSelector);
        // Loop to go through all rows
        for (i = 0; i < (rows.length - 1); i++) {
            let x,y;
            x = sortableParamCallback(rows[i]);
            y = sortableParamCallback(rows[i + 1]);
            x = typeof x == "string" ? x.toLowerCase() : x;
            y = typeof y == "string" ? y.toLowerCase() : y;

            if (direction == 'desc') {
                if (x > y) {
                    willSwitch = true
                    break;
                }
            } else {
                if (x < y) {
                    willSwitch = true
                    break;
                }
            }
        }
        if (willSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            stillSwitching = true;
        }
    }
}

export function initSortableColumn(sortableElementsSelector, headerSelector, callback) {
    $(headerSelector).click(function() {
        if($(this).attr('attr-direction') == 'asc') {
            $(this).attr('attr-direction', 'desc')
            sort(sortableElementsSelector, 'desc', callback);
        } else {
            $(this).attr('attr-direction', 'asc');
            sort(sortableElementsSelector, 'asc', callback);
        }
    });
}
