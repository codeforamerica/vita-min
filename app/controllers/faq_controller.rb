class FaqController < ApplicationController
  QUESTIONS = {
    stimulus: [
      :how_many_stimulus_payments_were_there,
      :will_there_be_another_stimulus_payment,
      :how_do_i_get_the_stimulus_payments,
      :what_is_the_economic_impact_payment,
      :what_is_the_recovery_rebate_credit
    ],
    child_tax_credit: [
      :what_is_the_child_tax_credit_ctc,
      :is_the_child_tax_credit_ctc_going_away,
      :how_do_i_get_my_child_tax_credit_ctc_payments,
      :do_i_have_to_report_my_advanced_child_tax_credit,
      :what_do_i_do_if_someone_else_has_claimed_my,
      :what_if_i_dont_have_any_income_or_only_income,
      :i_got_letter_6419_from_the_irs_what_is_it,
      :how_much_is_the_child_tax_credit_in_2022,
      :do_i_qualify_for_the_child_tax_credit_ctc,
      :i_was_getting_child_tax_credit_monthly_payments_in_2021,
      :how_do_i_get_the_child_tax_credit_if_i,
      :how_do_i_claim_child_tax_credit_for_a_baby_in_2021,
      :how_do_i_claim_child_tax_credit_for_a_baby_in_2022,
      :am_i_eligible_for_child_tax_credit_if_i_dont,
      :i_owe_back_child_support_can_i_still_get_all,
      :i_have_student_debt_can_i_still_get_all_of,
      :what_is_the_child_tax_credit_update_portal_ctc_up,
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
      :why_did_my_spouse_and_i_get_two_different_letters,
      :i_got_letter_6475_or_1444c_from_the_irs_what,
      :i_got_notice_cp09_or_cp27_from_the_irs_what,
      :i_got_notice_4883c_or_5071c_from_the_irs_what,
    ],
    nonfiler_portal: [
      :where_is_the_nonfiler_portal_where_is_getctc,
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
      :what_is_getyourrefund_express_and_how_does_it_work,
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
      :how_has_the_child_and_dependent_care_credit_changed,
      :how_do_i_get_the_child_and_dependent_care_credit,
    ],
    state_returns: [
      :do_i_have_to_file_a_state_return_if_i,
      :can_i_get_tax_credits_from_my_state,
      :can_i_get_tax_credits_from_california,
    ],
    puerto_rico: [
      :do_i_have_to_file_a_tax_return,
      :what_payments_am_i_eligible_for,
      :how_do_i_get_the_ctc_in_puerto_rico,
      :how_do_i_get_the_eitc_in_puerto_rico,
    ]
  }

  skip_before_action :check_maintenance_mode

  def include_analytics?
    true
  end

  def index
  end

  def section_index
    # validate that it is actually good, 404 if not

    @section_key = params[:section_key]

    raise ActionController::RoutingError.new('Not found') unless I18n.exists?("views.public_pages.faq.question_groups.#{@section_key}")
  end

  def show
    @section_key = params[:section_key]
    @question_key = params[:question_key].underscore
    @survey = FaqSurvey.find_or_initialize_by(visitor_id: visitor_id, question_key: @question_key)

    raise ActionController::RoutingError.new('Not found') unless I18n.exists?("views.public_pages.faq.question_groups.#{@section_key}.#{@question_key}")
  end

  def answer_survey
    @question_key = params[:question_key].underscore
    @survey = FaqSurvey.find_or_initialize_by(visitor_id: visitor_id, question_key: @question_key)

    @survey.update(params.require(:faq_survey).permit(:answer))
    redirect_to faq_question_path(section_key: params[:section_key], question_key: @question_key)
  end
end
