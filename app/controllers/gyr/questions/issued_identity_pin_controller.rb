module Questions
  class IssuedIdentityPinController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"
  end
end
