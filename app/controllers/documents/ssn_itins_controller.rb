module Documents
  class SsnItinsController < DocumentUploadQuestionController
    before_action :set_household_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::SsnItin
    end

    private

    def set_household_names
      @names = [current_intake.primary_full_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
      if current_intake.dependents.present?
        @names += current_intake.dependents.map(&:full_name)
      end
    end
  end
end
