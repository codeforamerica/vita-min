module Documents
  class Form1099bsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-B'

    def self.show?(intake)
      intake.had_asset_sale_income_yes?
    end
  end
end
