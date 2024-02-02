export function fetchStateFileEfileStateCounts() {
    $.rails.ajax({
        url: "efile_submissions/state-counts",
        type: "get",
    })
}