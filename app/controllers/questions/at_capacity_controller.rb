module Questions
  class AtCapacityController < QuestionsController
    include AnonymousIntakeConcern
    layout "application"

    def self.show?(intake)
      true
      intake.client.routing_method_at_capacity?
    end

    def edit
      if current_client.present? && current_client.routing_method != "at_capacity"
        redirect_to next_path
      end

      current_intake.update(viewed_at_capacity: true)
    end
  end
end
