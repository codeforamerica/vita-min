# frozen_string_literal: true

module Questions
  class PriorTaxReturnsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_local_tax_refund_yes? || intake.reported_asset_sale_loss_yes?
    end

    private

    def document_type
      "2018 Tax Return"
    end
  end
end
