module Documents
  class Form1095asController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1095-A'

    def self.show?(intake)
      intake.bought_health_insurance_yes?
    end
  end
end
