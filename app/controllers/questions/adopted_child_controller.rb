module Questions
  class AdoptedChildController < QuestionsController
    include AuthenticatedClientConcern

    def self.show?(intake) = false

    layout "yes_no_question"
  end
end
