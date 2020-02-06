module Questions
  class MailingAddressController < QuestionsController
    before_action :set_default_mailing_address, only: %i[edit]

    private

    def section_title
      "Personal Information"
    end

    def illustration_path; end

    def set_default_mailing_address
      return if current_intake.street_address.present?

      current_intake.assign_attributes(
        street_address: current_user.street_address,
        city: current_user.city,
        state: current_user.state,
        zip_code: current_user.zip_code,
      )
    end
  end
end
