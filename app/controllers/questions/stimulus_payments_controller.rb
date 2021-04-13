module Questions
  class StimulusPaymentsController < AuthenticatedIntakeController
    layout "yes_no_question"

    def illustration_path
      "hand-holding-check.svg"
    end

    def method_name
      "received_stimulus_payment"
    end
  end
end