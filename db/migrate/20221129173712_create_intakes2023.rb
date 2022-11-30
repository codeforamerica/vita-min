class CreateIntakes2023 < ActiveRecord::Migration[7.0]
  def change
    create_table :intakes do |t|
      t.string "additional_info"
      t.integer "adopted_child", default: 0, null: false
      t.integer "advance_ctc_amount_received"
      t.integer "advance_ctc_entry_method", default: 0, null: false
      t.integer "already_applied_for_stimulus", default: 0, null: false
      t.integer "already_filed", default: 0, null: false
      t.integer "balance_pay_from_bank", default: 0, null: false
      t.text "bank_account_number"
      t.integer "bank_account_type", default: 0, null: false
      t.string "bank_name"
      t.string "bank_routing_number"
      t.integer "bought_energy_efficient_items"
      t.integer "bought_health_insurance", default: 0, null: false
      t.integer "cannot_claim_me_as_a_dependent", default: 0, null: false
      t.string "canonical_email_address"
      t.string "city"
      t.integer "claim_eitc", default: 0, null: false
      t.integer "claim_owed_stimulus_money", default: 0, null: false
      t.integer "claimed_by_another", default: 0, null: false
      t.bigint "client_id"
      t.datetime "completed_at", precision: nil
      t.datetime "completed_yes_no_questions_at", precision: nil
      t.integer "consented_to_legal", default: 0, null: false
      t.boolean "continued_at_capacity", default: false
      t.datetime "created_at", null: false
      t.string "current_step"
      t.integer "demographic_disability", default: 0, null: false
      t.integer "demographic_english_conversation", default: 0, null: false
      t.integer "demographic_english_reading", default: 0, null: false
      t.boolean "demographic_primary_american_indian_alaska_native"
      t.boolean "demographic_primary_asian"
      t.boolean "demographic_primary_black_african_american"
      t.integer "demographic_primary_ethnicity", default: 0, null: false
      t.boolean "demographic_primary_native_hawaiian_pacific_islander"
      t.boolean "demographic_primary_prefer_not_to_answer_race"
      t.boolean "demographic_primary_white"
      t.integer "demographic_questions_opt_in", default: 0, null: false
      t.boolean "demographic_spouse_american_indian_alaska_native"
      t.boolean "demographic_spouse_asian"
      t.boolean "demographic_spouse_black_african_american"
      t.integer "demographic_spouse_ethnicity", default: 0, null: false
      t.boolean "demographic_spouse_native_hawaiian_pacific_islander"
      t.boolean "demographic_spouse_prefer_not_to_answer_race"
      t.boolean "demographic_spouse_white"
      t.integer "demographic_veteran", default: 0, null: false
      t.boolean "disallowed_ctc"
      t.integer "divorced", default: 0, null: false
      t.string "divorced_year"
      t.integer "eip1_amount_received"
      t.integer "eip1_and_2_amount_received_confidence"
      t.integer "eip1_entry_method", default: 0, null: false
      t.integer "eip2_amount_received"
      t.integer "eip2_entry_method", default: 0, null: false
      t.integer "eip3_amount_received"
      t.integer "eip3_entry_method", default: 0, null: false
      t.boolean "eip_only"
      t.citext "email_address"
      t.datetime "email_address_verified_at", precision: nil
      t.string "email_domain"
      t.integer "email_notification_opt_in", default: 0, null: false
      t.integer "ever_married", default: 0, null: false
      t.integer "ever_owned_home", default: 0, null: false
      t.integer "exceeded_investment_income_limit", default: 0
      t.string "feedback"
      t.integer "feeling_about_taxes", default: 0, null: false
      t.integer "filed_2020", default: 0, null: false
      t.integer "filed_prior_tax_year", default: 0, null: false
      t.integer "filing_for_stimulus", default: 0, null: false
      t.integer "filing_joint", default: 0, null: false
      t.string "final_info"
      t.integer "former_foster_youth", default: 0, null: false
      t.integer "full_time_student_less_than_five_months", default: 0, null: false
      t.integer "had_asset_sale_income", default: 0, null: false
      t.integer "had_debt_forgiven", default: 0, null: false
      t.integer "had_dependents", default: 0, null: false
      t.integer "had_disability", default: 0, null: false
      t.integer "had_disability_income", default: 0, null: false
      t.integer "had_disaster_loss", default: 0, null: false
      t.integer "had_disqualifying_non_w2_income"
      t.integer "had_farm_income", default: 0, null: false
      t.integer "had_gambling_income", default: 0, null: false
      t.integer "had_hsa", default: 0, null: false
      t.integer "had_interest_income", default: 0, null: false
      t.integer "had_local_tax_refund", default: 0, null: false
      t.integer "had_other_income", default: 0, null: false
      t.integer "had_rental_income", default: 0, null: false
      t.integer "had_retirement_income", default: 0, null: false
      t.integer "had_self_employment_income", default: 0, null: false
      t.integer "had_social_security_income", default: 0, null: false
      t.integer "had_social_security_or_retirement", default: 0, null: false
      t.integer "had_student_in_family", default: 0, null: false
      t.integer "had_tax_credit_disallowed", default: 0, null: false
      t.integer "had_tips", default: 0, null: false
      t.integer "had_unemployment_income", default: 0, null: false
      t.integer "had_w2s", default: 0, null: false
      t.integer "had_wages", default: 0, null: false
      t.boolean "has_crypto_income", default: false
      t.integer "has_primary_ip_pin", default: 0, null: false
      t.integer "has_spouse_ip_pin", default: 0, null: false
      t.string "hashed_primary_ssn"
      t.integer "home_location"
      t.integer "homeless_youth", default: 0, null: false
      t.integer "income_over_limit", default: 0, null: false
      t.string "interview_timing_preference"
      t.integer "irs_language_preference"
      t.integer "issued_identity_pin", default: 0, null: false
      t.integer "job_count"
      t.integer "lived_with_spouse", default: 0, null: false
      t.string "locale"
      t.integer "made_estimated_tax_payments", default: 0, null: false
      t.integer "married", default: 0, null: false
      t.integer "multiple_states", default: 0, null: false
      t.boolean "navigator_has_verified_client_identity"
      t.string "navigator_name"
      t.integer "need_itin_help", default: 0, null: false
      t.integer "needs_help_2016", default: 0, null: false
      t.integer "needs_help_2017", default: 0, null: false
      t.integer "needs_help_2018", default: 0, null: false
      t.integer "needs_help_2019", default: 0, null: false
      t.integer "needs_help_2020", default: 0, null: false
      t.integer "needs_help_2021", default: 0, null: false
      t.datetime "needs_to_flush_searchable_data_set_at", precision: nil
      t.integer "no_eligibility_checks_apply", default: 0, null: false
      t.integer "no_ssn", default: 0, null: false
      t.integer "not_full_time_student", default: 0, null: false
      t.string "other_income_types"
      t.integer "paid_alimony", default: 0, null: false
      t.integer "paid_charitable_contributions", default: 0, null: false
      t.integer "paid_dependent_care", default: 0, null: false
      t.integer "paid_local_tax", default: 0, null: false
      t.integer "paid_medical_expenses", default: 0, null: false
      t.integer "paid_mortgage_interest", default: 0, null: false
      t.integer "paid_retirement_contributions", default: 0, null: false
      t.integer "paid_school_supplies", default: 0, null: false
      t.integer "paid_student_loan_interest", default: 0, null: false
      t.string "phone_carrier"
      t.string "phone_number"
      t.integer "phone_number_can_receive_texts", default: 0, null: false
      t.string "phone_number_type"
      t.string "preferred_interview_language"
      t.string "preferred_name"
      t.string "preferred_written_language"
      t.integer "primary_active_armed_forces", default: 0, null: false
      t.date "primary_birth_date"
      t.integer "primary_consented_to_service", default: 0, null: false
      t.inet "primary_consented_to_service_ip"
      t.bigint "primary_drivers_license_id"
      t.string "primary_first_name"
      t.text "primary_ip_pin"
      t.text "primary_last_four_ssn"
      t.string "primary_last_name"
      t.string "primary_middle_initial"
      t.integer "primary_prior_year_agi_amount"
      t.string "primary_prior_year_signature_pin"
      t.text "primary_signature_pin"
      t.datetime "primary_signature_pin_at", precision: nil
      t.text "primary_ssn"
      t.string "primary_suffix"
      t.integer "primary_tin_type"
      t.integer "received_advance_ctc_payment"
      t.integer "received_alimony", default: 0, null: false
      t.integer "received_homebuyer_credit", default: 0, null: false
      t.integer "received_irs_letter", default: 0, null: false
      t.integer "received_stimulus_payment", default: 0, null: false
      t.string "referrer"
      t.integer "refund_payment_method", default: 0, null: false
      t.integer "reported_asset_sale_loss", default: 0, null: false
      t.integer "reported_self_employment_loss", default: 0, null: false
      t.string "requested_docs_token"
      t.datetime "requested_docs_token_created_at", precision: nil
      t.datetime "routed_at", precision: nil
      t.string "routing_criteria"
      t.string "routing_value"
      t.integer "satisfaction_face", default: 0, null: false
      t.integer "savings_purchase_bond", default: 0, null: false
      t.integer "savings_split_refund", default: 0, null: false
      t.tsvector "searchable_data"
      t.integer "separated", default: 0, null: false
      t.string "separated_year"
      t.integer "signature_method", default: 0, null: false
      t.integer "sms_notification_opt_in", default: 0, null: false
      t.string "sms_phone_number"
      t.datetime "sms_phone_number_verified_at", precision: nil
      t.integer "sold_a_home", default: 0, null: false
      t.integer "sold_assets", default: 0, null: false
      t.string "source"
      t.integer "spouse_active_armed_forces", default: 0
      t.string "spouse_auth_token"
      t.date "spouse_birth_date"
      t.integer "spouse_consented_to_service", default: 0, null: false
      t.datetime "spouse_consented_to_service_at", precision: nil
      t.inet "spouse_consented_to_service_ip"
      t.bigint "spouse_drivers_license_id"
      t.citext "spouse_email_address"
      t.integer "spouse_filed_prior_tax_year", default: 0, null: false
      t.string "spouse_first_name"
      t.integer "spouse_had_disability", default: 0, null: false
      t.text "spouse_ip_pin"
      t.integer "spouse_issued_identity_pin", default: 0, null: false
      t.text "spouse_last_four_ssn"
      t.string "spouse_last_name"
      t.string "spouse_middle_initial"
      t.integer "spouse_prior_year_agi_amount"
      t.string "spouse_prior_year_signature_pin"
      t.text "spouse_signature_pin"
      t.datetime "spouse_signature_pin_at", precision: nil
      t.text "spouse_ssn"
      t.string "spouse_suffix"
      t.integer "spouse_tin_type"
      t.integer "spouse_was_blind", default: 0, null: false
      t.integer "spouse_was_full_time_student", default: 0, null: false
      t.integer "spouse_was_on_visa", default: 0, null: false
      t.string "state"
      t.string "state_of_residence"
      t.string "street_address"
      t.string "street_address2"
      t.string "timezone"
      t.integer "triage_filing_frequency", default: 0, null: false
      t.integer "triage_filing_status", default: 0, null: false
      t.integer "triage_income_level", default: 0, null: false
      t.integer "triage_vita_income_ineligible", default: 0, null: false
      t.string "type"
      t.datetime "updated_at", null: false
      t.string "urbanization"
      t.boolean "use_primary_name_for_name_control", default: false
      t.boolean "used_itin_certifying_acceptance_agent", default: false, null: false
      t.integer "usps_address_late_verification_attempts", default: 0
      t.datetime "usps_address_verified_at"
      t.boolean "viewed_at_capacity", default: false
      t.string "visitor_id"
      t.bigint "vita_partner_id"
      t.string "vita_partner_name"
      t.integer "wants_to_itemize", default: 0, null: false
      t.integer "was_blind", default: 0, null: false
      t.integer "was_full_time_student", default: 0, null: false
      t.integer "was_on_visa", default: 0, null: false
      t.integer "widowed", default: 0, null: false
      t.string "widowed_year"
      t.boolean "with_drivers_license_photo_id", default: false
      t.boolean "with_general_navigator", default: false
      t.boolean "with_incarcerated_navigator", default: false
      t.boolean "with_itin_taxpayer_id", default: false
      t.boolean "with_limited_english_navigator", default: false
      t.boolean "with_other_state_photo_id", default: false
      t.boolean "with_passport_photo_id", default: false
      t.boolean "with_social_security_taxpayer_id", default: false
      t.boolean "with_unhoused_navigator", default: false
      t.boolean "with_vita_approved_photo_id", default: false
      t.boolean "with_vita_approved_taxpayer_id", default: false
      t.string "zip_code"
      t.index ["canonical_email_address"], name: "index_intakes_on_canonical_email_address"
      t.index ["client_id"], name: "index_intakes_on_client_id"
      t.index ["completed_at"], name: "index_intakes_on_completed_at", where: "(completed_at IS NOT NULL)"
      t.index ["email_address"], name: "index_intakes_on_email_address"
      t.index ["email_domain"], name: "index_intakes_on_email_domain"
      t.index ["hashed_primary_ssn"], name: "index_intakes_on_hashed_primary_ssn"
      t.index ["needs_to_flush_searchable_data_set_at"], name: "index_intakes_on_needs_to_flush_searchable_data_set_at", where: "(needs_to_flush_searchable_data_set_at IS NOT NULL)"
      t.index ["phone_number"], name: "index_intakes_on_phone_number"
      t.index ["primary_consented_to_service"], name: "index_intakes_on_primary_consented_to_service"
      t.index ["primary_drivers_license_id"], name: "index_intakes_on_primary_drivers_license_id"
      t.index ["searchable_data"], name: "index_intakes_on_searchable_data", using: :gin
      t.index ["sms_phone_number"], name: "index_intakes_on_sms_phone_number"
      t.index ["spouse_drivers_license_id"], name: "index_intakes_on_spouse_drivers_license_id"
      t.index ["spouse_email_address"], name: "index_intakes_on_spouse_email_address"
      t.index ["type"], name: "index_intakes_on_type"
      t.index ["vita_partner_id"], name: "index_intakes_on_vita_partner_id"
    end

    safety_assured do
      add_foreign_key "intakes", "clients"
      add_foreign_key "intakes", "vita_partners"
    end

    set_pk_sequence!(
      'intakes',
      '(SELECT MAX(id) FROM archived_intakes_2022)'
    )
  end
end
