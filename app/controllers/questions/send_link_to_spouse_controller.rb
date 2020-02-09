module Questions
  class SendLinkToSpouseController < QuestionsController
    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def section_title
      "Personal Information"
    end

    def illustration_path; end

    def after_update_success
      SendSpouseVerificationRequestJob.perform_later(@form.spouse_verification_request.id)
    end

    def form_params
      permitted_params = super
      permitted_params[:phone_number] = parse_phone_number(permitted_params[:phone_number])
      permitted_params
    end

    def parse_phone_number(value)
      if value.present? && value.is_a?(String)
        unless value[0] == "1" || value[0..1] == "+1"
          value = "1#{value}" # add USA country code
        end
        Phonelib.parse(value).sanitized
      else
        value
      end
    end
  end
end