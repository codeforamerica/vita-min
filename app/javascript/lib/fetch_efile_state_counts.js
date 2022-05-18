export function fetchEfileStateCounts() {
    Rails.ajax({
        url: "/hub/efile/state-counts",
        type: "get",
        data: "",
        success: function(data) {},
        error: function(data) {}
    })
}