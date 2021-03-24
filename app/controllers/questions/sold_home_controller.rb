module Questions
  class SoldHomeController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "sold_a_home"
    end
  end
end
