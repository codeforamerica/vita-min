module Questions
  class IrsLetterController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "received_irs_letter"
    end
  end
end