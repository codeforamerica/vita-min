module Documents
  class SsnItinsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.dependents.present?
    end

    def edit
      dependent_names = current_intake.dependents.map { |dependent| "#{dependent.first_name} #{dependent.last_name}" }.join(", ")
      @help_text = "Earlier, you told us that you have dependents. We need to verify this by seeing a Social Security Card or ITIN Paperwork.<br/>Please share an image of a Social Security Card or ITIN Paperwork for these dependents: #{dependent_names}".html_safe
      super
    end
  end
end
