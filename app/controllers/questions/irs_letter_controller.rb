module Questions
  class IrsLetterController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "received_irs_letter"
    end
  end
end