module StateFile
  class IdDonationsForm < QuestionsForm
    set_attributes_for(
      :intake,
      :nongame_wildlife_fund_donation,
      :childrens_trust_fund_donation,
      :special_olympics_donation,
      :guard_reserve_family_donation,
      :american_red_cross_fund_donation,
      :veterans_support_fund_donation,
      :food_bank_fund_donation,
      :opportunity_scholarship_program_donation
    )

    NON_ZERO_REQUIRED_FIELDS = [
      :nongame_wildlife_fund_donation,
      :childrens_trust_fund_donation,
      :special_olympics_donation,
      :guard_reserve_family_donation,
      :american_red_cross_fund_donation,
      :veterans_support_fund_donation,
      :food_bank_fund_donation,
      :opportunity_scholarship_program_donation
    ]

    validates *NON_ZERO_REQUIRED_FIELDS, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

    def save
      attributes_to_save = attributes_for(:intake)
      @intake.update!(attributes_to_save)
    end
  end
end
