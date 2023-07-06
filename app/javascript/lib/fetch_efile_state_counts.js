export function fetchEfileStateCounts() {
    $.rails.ajax({
        url: "/hub/efile/state-counts",
        type: "get",
    })
}