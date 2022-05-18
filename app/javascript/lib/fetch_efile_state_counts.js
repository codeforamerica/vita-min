export function fetchEfileStateCounts() {
    Rails.ajax({
        url: "/hub/efile/state-counts",
        type: "get",
    })
}