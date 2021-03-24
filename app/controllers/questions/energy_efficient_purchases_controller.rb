module Questions
  class EnergyEfficientPurchasesController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "bought_energy_efficient_items"
    end
  end
end
