module Questions
  class HomebuyerCreditController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_owned_home_yes?
    end

    private

    def method_name
      "received_homebuyer_credit"
    end
  end
end