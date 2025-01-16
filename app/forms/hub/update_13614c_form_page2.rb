module Hub
  class Update13614cFormPage2 < Form
    include FormAttributes

    set_attributes_for :intake,

                       :had_wages,
                       :job_count,

                       :had_tips,

                       :had_retirement_income,

                       :had_disability_income,

                       :had_social_security_income,

                       :had_unemployment_income,

                       :had_local_tax_refund,

                       :had_interest_income,

                       :had_asset_sale_income,
                       :reported_asset_sale_loss,

                       :received_alimony,

                       :had_rental_income,
                       :had_rental_income_and_used_dwelling_as_residence,
                       :had_rental_income_from_personal_property,

                       :had_gambling_income,

                       :had_self_employment_income,
                       :reported_self_employment_loss,

                       :had_other_income,

                       :cv_w2s_cb,
                       :cv_w2s_count,

                       :cv_had_tips_cb,

                       :cv_1099r_cb,
                       :cv_1099r_count,
                       :cv_1099r_charitable_dist_cb,
                       :cv_1099r_charitable_dist_amt,

                       :cv_disability_benefits_1099r_or_w2_cb,
                       :cv_disability_benefits_1099r_or_w2_count,

                       :cv_ssa1099_rrb1099_cb,
                       :cv_ssa1099_rrb1099_count,

                       :cv_1099g_cb,
                       :cv_1099g_count,

                       :cv_local_tax_refund_cb,
                       :cv_local_tax_refund_amt,
                       :cv_itemized_last_year_cb,

                       :cv_1099int_cb,
                       :cv_1099int_count,
                       :cv_1099div_cb,
                       :cv_1099div_count,

                       :cv_1099b_cb,
                       :cv_1099b_count,
                       :cv_capital_loss_carryover_cb,

                       :cv_alimony_income_cb,
                       :cv_alimony_income_amt,
                       :cv_alimony_excluded_from_income_cb,

                       :cv_rental_income_cb,
                       :cv_rental_expense_cb,
                       :cv_rental_expense_amt,

                       :cv_w2g_or_other_gambling_winnings_cb,
                       :cv_w2g_or_other_gambling_winnings_count,

                       :cv_schedule_c_cb,
                       :cv_1099misc_cb,
                       :cv_1099misc_count,
                       :cv_1099nec_cb,
                       :cv_1099nec_count,
                       :cv_1099k_cb,
                       :cv_1099k_count,
                       :cv_other_income_reported_elsewhere_cb,
                       :cv_schedule_c_expenses_cb,
                       :cv_schedule_c_expenses_amt,

                       :cv_other_income_cb,

                       :cv_p2_notes_comments

    attr_accessor :client

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    # override what's in FormAttribute to prevent nils (which
    # are causing database errors)
    def attributes_for(model)
      self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
        v = send(attribute_name)
        hash[attribute_name] = v ? v : 'unfilled'
        hash
      end
    end

    def save
      return false unless valid?

      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end
