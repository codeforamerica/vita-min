module Diy
  class EmailAddressController < DiyController
    def tracking_data
      {}
    end

    def self.form_name
      "diy_email_address_form"
    end

    def after_update_success
      duplicate_diy_intake = current_diy_intake.duplicate_diy_intakes.first
      if duplicate_diy_intake.present?
        current_diy_intake.update(requester_id: duplicate_diy_intake.requester_id, ticket_id: duplicate_diy_intake.ticket_id)
      end
    end
  end
end
