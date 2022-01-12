module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      unless Client.after_consent.where(intake: current_intake).exists?
        routing_service = PartnerRoutingService.new(
          intake: current_intake,
          source_param: current_intake.source,
          zip_code: current_intake.zip_code,
        )
        current_intake.client.update(vita_partner: routing_service.determine_partner, routing_method: routing_service.routing_method)
      end
    end

    def next_path
      current_intake.vita_partner.present? ? super : at_capacity_questions_path
    end
  end
end
