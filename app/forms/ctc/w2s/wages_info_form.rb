module Ctc
  module W2s
    class WagesInfoForm < W2Form
      set_attributes_for(
        :w2,
        :wages_amount,
        :federal_income_tax_withheld,
        :box3_social_security_wages,
        :box4_social_security_tax_withheld,
        :box5_medicare_wages_and_tip_amount,
        :box6_medicare_tax_withheld,
        :box7_social_security_tips_amount,
        :box8_allocated_tips,
        :box10_dependent_care_benefits
      )

      validates :wages_amount, gyr_numericality: { greater_than_or_equal_to: 0.5 }, presence: true
      validates :federal_income_tax_withheld, presence: true, gyr_numericality: true
      validates :federal_income_tax_withheld, gyr_numericality: { less_than: :wages_amount }, if: -> { errors[:wages_amount].blank? }

      validates :box3_social_security_wages, gyr_numericality: true, allow_blank: true
      validates :box4_social_security_tax_withheld, gyr_numericality: true, allow_blank: true
      validates :box5_medicare_wages_and_tip_amount, gyr_numericality: true, allow_blank: true
      validates :box6_medicare_tax_withheld, gyr_numericality: true, allow_blank: true
      validates :box7_social_security_tips_amount, gyr_numericality: true, allow_blank: true
      validates :box8_allocated_tips, gyr_numericality: true, allow_blank: true
      validates :box10_dependent_care_benefits, gyr_numericality: true, allow_blank: true
    end
  end
end
