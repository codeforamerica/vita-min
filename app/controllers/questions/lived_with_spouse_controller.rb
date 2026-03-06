module Questions
  class LivedWithSpouseController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_married_yes?
    end

    private

    def method_name
      'lived_without_spouse'
    end
  end
end
