module Questions
  class ArpPaymentsController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def illustration_path
      "hand-holding-check.svg"
    end
  end
end