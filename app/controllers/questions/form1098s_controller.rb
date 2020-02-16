# frozen_string_literal: true

module Questions
  class Form1098sController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_mortgage_interest_yes? || intake.paid_local_tax_yes?
    end

    private

    def document_type
      "1098"
    end
  end
end
