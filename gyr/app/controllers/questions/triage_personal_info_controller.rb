module Questions
  class TriagePersonalInfoController < PersonalInfoController
    before_action :redirect_if_matching_source_param

    def self.show?(_intake)
      true
    end

    def redirect_if_matching_source_param
      redirect_to_intake_after_triage if SourceParameter.source_skips_triage(session[:source])
    end
  end
end
