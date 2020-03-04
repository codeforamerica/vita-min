module Documents
  class SsnItinsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.dependents.present?
    end

    def edit
      @dependent_names = current_intake.dependents.map { |dependent| "#{dependent.first_name} #{dependent.last_name}" }
      super
    end
  end
end
