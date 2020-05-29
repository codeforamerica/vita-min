module Documents
  class IdsController < DocumentUploadQuestionController
    def edit
      @names = [current_intake.primary_full_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
      super
    end

    def self.document_type
      "ID"
    end
  end
end
