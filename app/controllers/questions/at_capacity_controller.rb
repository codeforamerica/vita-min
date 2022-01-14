module Questions
  class AtCapacityController < QuestionsController
    include AnonymousIntakeConcern
    layout "application"

    def self.show?(intake)
      intake.client.routing_method_at_capacity?
    end

    def edit
      current_intake.update(viewed_at_capacity: true)
    end
  end
end
