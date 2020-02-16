# frozen_string_literal: true

module Questions
  class Form1095asController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.bought_health_insurance_yes?
    end

    private

    def document_type
      "1095-A"
    end
  end
end
