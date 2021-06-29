module Questions
  class EverOwnedHomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "ever_owned_home"
    end
  end
end
