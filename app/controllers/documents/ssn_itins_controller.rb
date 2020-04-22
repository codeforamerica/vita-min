module Documents
  class SsnItinsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'SSN or ITIN'.freeze

    def self.show?(intake)
      intake.dependents.present?
    end

    def edit
      @dependent_names = current_intake.dependents.map(&:full_name)
      super
    end
  end
end
