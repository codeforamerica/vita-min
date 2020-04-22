module Documents
  class SsnItinsController < DocumentUploadQuestionController
    def edit
      @names = [current_intake.primary_full_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
      if current_intake.dependents.present?
        @names += current_intake.dependents.map(&:full_name)
      end
      super
    end

    def next_path
      return selfie_instructions_documents_path
    end

    def self.document_type
      "SSN or ITIN"
    end
  end
end
