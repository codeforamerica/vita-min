module Hub
  class Update13614cFormPage3 < Form
    include FormAttributes

    set_attributes_for :intake,
                       :paid_mortgage_interest,
                       :paid_local_tax,
                       :paid_medical_expenses,
                       :paid_charitable_contributions,
                       :paid_student_loan_interest,
                       :paid_dependent_care,
                       :paid_retirement_contributions,
                       :paid_school_supplies,
                       :paid_alimony,
                       :paid_post_secondary_educational_expenses,
                       :sold_a_home,
                       :had_hsa,
                       :bought_marketplace_health_insurance,
                       :bought_energy_efficient_items,
                       :had_debt_forgiven,
                       :had_disaster_loss,
                       :had_tax_credit_disallowed,
                       :received_irs_letter,
                       :made_estimated_tax_payments,
                       :cv_med_expense_standard_deduction_cb,
                       :cv_med_expense_itemized_deduction_cb,
                       :cv_1098e_cb,
                       :cv_child_dependent_care_credit_cb,
                       :contributed_to_ira,
                       :cv_edu_expenses_deduction_cb,
                       :cv_edu_expenses_deduction_amt,
                       :cv_paid_alimony_w_spouse_ssn_cb,
                       :cv_paid_alimony_w_spouse_ssn_amt,
                       :cv_alimony_income_adjustment_yn_cb,
                       :cv_taxable_scholarship_income_cb,
                       :cv_1098t_cb,
                       :cv_edu_credit_or_tuition_deduction_cb,
                       :cv_1099s_cb,
                       :cv_hsa_contrib_cb,
                       :cv_hsa_distrib_cb,
                       :cv_1095a_cb,
                       :cv_energy_efficient_home_improv_credit_cb,
                       :cv_1099c_cb,
                       :cv_1099a_cb,
                       :cv_disaster_relief_impacts_return_cb,
                       :cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb,
                       :tax_credit_disallowed_year,
                       :cv_tax_credit_disallowed_reason,
                       :cv_eligible_for_litc_referral_cb,
                       :made_estimated_tax_payments_amount,
                       :cv_estimated_tax_payments_cb,
                       :cv_estimated_tax_payments_amt,
                       :cv_last_years_refund_applied_to_this_yr_cb,
                       :cv_last_years_refund_applied_to_this_yr_amt,
                       :cv_last_years_return_available_cb,
                       :cv_14c_page_3_notes_part_1,
                       :cv_14c_page_3_notes_part_2,
                       :cv_14c_page_3_notes_part_3

    attr_accessor :client

    # override what's in FormAttribute to prevent nils (which
    # are causing database null violation errors)
    def attributes_for(model)
      skip = [:cv_1098_count,
              :cv_edu_expenses_deduction_amt,
              :cv_paid_alimony_w_spouse_ssn_amt,
              :tax_credit_disallowed_year,
              :cv_tax_credit_disallowed_reason,
              :made_estimated_tax_payments_amount,
              :cv_estimated_tax_payments_amt,
              :cv_last_years_refund_applied_to_this_yr_amt,
              :cv_14c_page_3_notes_part_1,
              :cv_14c_page_3_notes_part_2,
              :cv_14c_page_3_notes_part_3]
      self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
        v = send(attribute_name)
        unless skip.include? attribute_name
          hash[attribute_name] = v ? v : 'unfilled'
        else
          hash[attribute_name] = v
        end
        hash
      end
    end

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end
