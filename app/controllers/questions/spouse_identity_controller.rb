module Questions
  class SpouseIdentityController < QuestionsController
    layout "question"

    def edit
      if params[:missing_spouse]
        @missing_spouse_notice = "Oops! It looks like you signed in as your spouse. <b>Please sign your spouse in with ID.me so we can verify their identity.</b>".html_safe
      end
    end

    def section_title
      "Personal Information"
    end

    def self.form_class
      NullForm
    end

    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end