module Documents
  class Form1095asController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.bought_health_insurance_yes?
    end

    def self.document_type
      "1095-A"
    end
  end
end
