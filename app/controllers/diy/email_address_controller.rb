module Diy
  class EmailAddressController < DiyController
    def tracking_data
      {}
    end

    def self.form_name
      "diy_email_address_form"
    end

    def after_update_success
      CreateZendeskDiyIntakeTicketJob.perform_later(current_diy_intake.id)
    end
  end
end
