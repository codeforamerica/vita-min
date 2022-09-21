module Ctc
  module W2s
    class WagesInfoForm < W2Form
      set_attributes_for(
        :w2,
        :wages_amount,
        :federal_income_tax_withheld,
      )

      validates :wages_amount, gyr_numericality: true, presence: true
      validates :federal_income_tax_withheld, gyr_numericality: true, presence: true
    end
  end
end
