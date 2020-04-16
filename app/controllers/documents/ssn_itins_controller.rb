module Documents
  class SsnItinsController < DocumentUploadQuestionController
    def edit
      # TODO: replace this with name from intake
      @names = [current_intake.primary_user.full_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
      if current_intake.dependents.present?
        @names += current_intake.dependents.map(&:full_name)
      end
      super
    end
  end
end
