module Questions
  class TriagePersonalInfoController < PersonalInfoController
    before_action :redirect_if_matching_source_param
    before_action :redirect_if_completed_intake_present

    def self.show?(_intake)
      true
    end

    def redirect_if_matching_source_param
      redirect_to_intake_after_triage if SourceParameter.source_skips_triage(session[:source])
    end

    def redirect_if_completed_intake_present
      if current_intake && current_intake.completed_at.present?
        redirect_to portal_root_path
      end
    end
  end
end
