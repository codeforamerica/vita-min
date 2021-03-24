module Questions
  class HomebuyerCreditController < AuthenticatedIntakeController
    layout "yes_no_question"

    def method_name
      "received_homebuyer_credit"
    end
  end
end