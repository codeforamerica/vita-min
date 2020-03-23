module Questions
  class SpouseConsentController < ConsentController
    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def after_update_success
      if session[:authenticate_spouse_only]
        SendSpouseAuthDocsToZendeskJob.perform_later(current_intake.id)
      end
    end

    def next_path
      if session[:authenticate_spouse_only]
        verify_spouse_done_path
      else
        super
      end
    end
  end
end
