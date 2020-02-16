module Documents
  class Form1099ssController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_asset_sale_income_yes? || intake.sold_a_home_yes?
    end
  end
end
