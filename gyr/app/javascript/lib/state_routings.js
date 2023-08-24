export function initStateRoutingsListeners() {
    updateRoutingPercentage();
    $(".routing-percentage-input-wrapper input").on("keyup", function(e) {
        updateRoutingPercentage();
    });

    // Logic for hiding an unpersisted "add routing" element
    $('.state-routings-edit').on('click', '.delete-unpersisted-state-routing-item', function(){
        $(this).parent().find(":input").prop("disabled", true);
        $(this).parent().hide();
    });
}

function updateRoutingPercentage() {
    let sum = 0;
    $(".routing-percentage-input-wrapper input").each(function() {
        sum += Number($(this).val());
    });
    $(".routing-percentage-total").text(`${sum}%`);
    if (sum != 100) {
        $(".routing-percentage-total").addClass("text--error");
    } else {
        $(".routing-percentage-total").removeClass("text--error");
    }
    return sum;
}

