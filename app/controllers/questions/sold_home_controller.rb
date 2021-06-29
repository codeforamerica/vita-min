module Questions
  class SoldHomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_owned_home_yes?
    end

    private

    def method_name
      "sold_a_home"
    end
  end
end
