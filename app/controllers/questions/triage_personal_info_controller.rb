module Questions
  class TriagePersonalInfoController < PersonalInfoController
    before_action :redirect_if_matching_source_param

    def self.show?(intake)
      true
    end

    def self.form_class
      PersonalInfoForm
    end

    def self.form_key
      "personal_info_form"
    end

    def redirect_if_matching_source_param
      redirect_to_intake_after_triage if SourceParameter.find_vita_partner_by_code(session[:source]).present?
    end
  end
end
