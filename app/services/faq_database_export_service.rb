class FaqDatabaseExportService
  def self.export_yml_to_database
    en_yml = YAML.load_file(Rails.root.join('app', 'services', 'faq_database_export_en.yml'))['question_groups']
    es_yml = YAML.load_file(Rails.root.join('app', 'services', 'faq_database_export_es.yml'))['question_groups']

    category_position = 0
    QUESTIONS.each do |section, questions|
      category_position += 1
      faq_category = FaqCategory.find_or_initialize_by(
        slug: section,
        product_type: :gyr
      )
      faq_category.update(
        name_en: en_yml[section.to_s]['title'],
        name_es: es_yml[section.to_s]['title'],
        position: category_position
      )
      question_position = 0
      questions.each do |question|
        question_position += 1
        faq_item = FaqItem.find_or_initialize_by(
          faq_category: faq_category,
          slug: question,
        )
        faq_item.update(
          position: question_position,
          question_en: en_yml[section.to_s][question.to_s]['question'],
          question_es: es_yml[section.to_s][question.to_s]['question'],
          answer_en: en_yml[section.to_s][question.to_s]['answer_html'],
          answer_es: es_yml[section.to_s][question.to_s]['answer_html'],
        )
      end
    end

    FaqQuestionGroupItem.find_or_create_by(group_name: "home_page", faq_item: FaqItem.find_by(slug: "how_do_i_get_the_stimulus_payments"), position: 1)
    FaqQuestionGroupItem.find_or_create_by(group_name: "home_page", faq_item: FaqItem.find_by(slug: "what_are_the_potential_benefits_of_filing_a_tax_return"), position: 2)
    FaqQuestionGroupItem.find_or_create_by(group_name: "home_page", faq_item: FaqItem.find_by(slug: "am_i_a_nonfiler"), position: 3)
  end

  QUESTIONS = {
    stimulus: [
      :how_many_stimulus_payments_were_there,
      :will_there_be_another_stimulus_payment,
      :how_do_i_get_the_stimulus_payments,
      :what_is_the_economic_impact_payment,
      :what_is_the_recovery_rebate_credit
    ],
    child_tax_credit: [
      :how_much_is_the_child_tax_credit_in_2022,
      :i_was_getting_child_tax_credit_monthly_payments_in_2021,
      :how_do_i_claim_child_tax_credit_for_a_baby_in_2023,
      :am_i_eligible_for_child_tax_credit_if_i_dont,
      :i_owe_back_child_support_can_i_still_get_all,
      :why_did_my_spouse_and_i_get_two_different_letters,
    ],
    who_should_i_include_on_my_tax_return: [
      :who_can_i_claim_on_my_return,
      :what_are_the_benefits_of_claiming_a_child_on_my,
      :can_i_claim_my_parent,
      :what_should_i_do_if_i_was_claimed_as_a,
    ],
    income: [
      :what_do_you_mean_by_selfemployed,
      :how_do_i_report_my_income_if_im_selfemployed,
      :what_expenses_can_i_claim_if_im_selfemployed,
      :are_my_disability_benefits_income,
      :are_my_snap_benefits_income,
      :are_my_unemployment_benefits_income,
    ],
    i_got_a_letter_from_the_irs: [
      :i_got_letter_6419_from_the_irs_what_is_it,
      :i_got_letter_6475_or_1444c_from_the_irs_what,
      :i_got_notice_cp09_or_cp27_from_the_irs_what,
      :i_got_notice_4883c_or_5071c_from_the_irs_what,
    ],
    im_nervous_about_filing_and_claiming_tax_benefits: [
      :what_do_i_do_if_im_audited_by_the_irs,
      :will_i_need_to_repay_any_of_my_refund,
      :will_claiming_these_credits_make_me_ineligible_for_other_government,
      :are_tax_credits_considered_in_public_charge_determinations,
      :what_if_i_havent_filed_for_years,
    ],
    documents: [
      :why_do_you_need_my_social_security_card,
      :how_do_i_replace_my_social_security_card,
      :how_do_i_get_my_w2_employment_document,
      :how_do_i_get_my_1099_employment_document,
    ],
    return_rejection_next_steps: [
      :what_is_an_ip_pin_and_how_do_i_find,
      :what_is_agi_and_how_do_i_find_it,
      :the_irs_says_i_already_filed_what_do_i_do,
      :the_irs_says_somebody_claimed_my_child,
    ],
    security_and_confidentiality: [
      :how_do_you_keep_my_data_safe,
      :can_ice_get_my_data,
    ],
    getyourrefund_account_access: [
      :what_is_my_client_id_number,
      :i_cant_sign_in,
    ],
    how_does_getyourrefund_work: [
      :what_is_getyourrefund_deluxe_and_how_does_it_work,
      :what_is_file_myself_and_how_does_it_work,
    ],
    should_i_file_a_tax_return: [
      :what_are_the_potential_benefits_of_filing_a_tax_return,
      :am_i_a_nonfiler,
      :im_under_19_should_i_file_a_tax_return,
      :im_1924_should_i_file_a_tax_return,
    ],
    earned_income_tax_credit: [
      :what_is_the_earned_income_tax_credit_eitc,
      :how_has_the_earned_income_tax_credit_eitc_changed_this,
    ],
    itin_filing_for_people_without_a_social_security_number: [
      :what_is_an_itin_itin_number,
      :how_do_i_get_an_itin,
      :if_i_file_my_taxes_can_ice_get_my_data,
    ],
    paper_filing: [
      :why_would_i_paper_file_my_tax_return,
      :how_do_i_paper_file,
      :where_should_i_mail_my_tax_return,
    ],
    where_are_my_payments: [
      :how_long_does_it_take_to_get_my_refund_after,
      :how_do_i_check_the_status_of_my_payments,
      :how_do_i_log_into_my_account_on_the_irs_website,
    ],
    child_and_dependent_care_credit: [
      :what_is_the_child_and_dependent_care_credit,
      :how_do_i_get_the_child_and_dependent_care_credit,
    ],
    state_returns: [
      :can_i_get_tax_credits_from_my_state,
      :can_i_get_tax_credits_from_california,
    ],
    puerto_rico: [
      :do_i_have_to_file_a_tax_return,
      :how_do_i_get_the_eitc_in_puerto_rico,
    ]
  }.freeze
end