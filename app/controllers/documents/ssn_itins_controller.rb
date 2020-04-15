module Documents
  class SsnItinsController < DocumentUploadQuestionController
    def edit
      @names = [current_intake.primary_user.full_name]
      if current_intake.filing_joint? && current_intake.spouse.present?
        @names << current_intake.spouse.full_name
      end
      if current_intake.dependents.present?
        @names += current_intake.dependents.map(&:full_name)
      end
      super
    end
  end
end
