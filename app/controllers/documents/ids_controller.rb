module Documents
  class IdsController < DocumentUploadQuestionController
    def edit
      @title = "Attach a photo of your ID card"
      @help_text = "The IRS requires us to see a current drivers license, passport, or state ID."
      @names = [current_intake.primary_user.full_name]
      if current_intake.filing_joint_yes?
        @title = "Attach photos of ID cards"
        @help_text = "The IRS requires us to see a current drivers license, passport, or state ID for you and your spouse."
        @names << current_intake.spouse_name_or_placeholder
      end
      super
    end
  end
end
