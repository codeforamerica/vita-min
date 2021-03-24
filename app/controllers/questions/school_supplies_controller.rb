module Questions
  class SchoolSuppliesController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "paid_school_supplies"
    end
  end
end
