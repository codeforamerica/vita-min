module Questions
  class PersonalInfoController < AnonymousIntakeController
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      unless Client.after_consent.where(intake: current_intake).exists?
        routing_service = PartnerRoutingService.new(
          source_param: current_intake.source,
          zip_code: current_intake.zip_code,
        )
        vita_partner = routing_service.determine_partner

        current_intake.client.update(vita_partner: vita_partner, routing_method: routing_service.routing_method)
        current_intake.update(vita_partner: vita_partner)
      end
    end
  end
end
