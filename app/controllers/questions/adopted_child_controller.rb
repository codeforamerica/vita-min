module Questions
  class AdoptedChildController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"
  end
end