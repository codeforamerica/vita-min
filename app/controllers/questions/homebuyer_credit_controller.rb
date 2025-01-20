module Questions
  class HomebuyerCreditController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake) = false

    private

    def method_name
      "received_homebuyer_credit"
    end
  end
end