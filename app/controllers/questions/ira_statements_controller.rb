# frozen_string_literal: true

module Questions
  class IraStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_retirement_contributions_yes?
    end

    private

    def document_type
      "IRA Statement"
    end
  end
end
