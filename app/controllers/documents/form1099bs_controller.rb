module Documents
  class Form1099bsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_asset_sale_income_yes?
    end

    def self.document_type
      "1099-B"
    end
  end
end
