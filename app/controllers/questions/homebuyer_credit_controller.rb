module Questions
  class HomebuyerCreditController < QuestionsController
    layout "yes_no_question"

    def method_name
      "received_homebuyer_credit"
    end
  end
end