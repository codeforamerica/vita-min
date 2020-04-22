module Documents
  class PriorTaxReturnsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '2018 Tax Return'.freeze

    def self.show?(intake)
      intake.had_local_tax_refund_yes? || intake.reported_asset_sale_loss_yes?
    end
  end
end
