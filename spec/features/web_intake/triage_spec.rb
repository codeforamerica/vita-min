require "rails_helper"

RSpec.feature "triage flow", :flow_explorer_screenshot do
  scenario "client's income is over the income limit" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_over_73000"
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageDoNotQualifyController
    ].map(&:to_path_helper))
  end

  scenario "client's income is eligible for DIY but not full service" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_66000_to_73000"
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageReferralController
    ].map(&:to_path_helper))
  end

  scenario "client does not have any documents and needs help" do
    pages = answer_gyr_triage_questions(
      income_level: "zero",
      id_type: "have_paperwork",
      doc_type: "need_help_html",
      income_type_options: ['none_of_the_above']
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageIncomeTypesController,
      Questions::TriageGyrController
    ].map(&:to_path_helper))
  end

  scenario "client with small non-zero income who doesn't need assistance is routed to diy" do
    # To be eligible for free DIY from our perspective, they need to have filed the previous years' returns.
    pages = answer_gyr_triage_questions(
      income_level: "hh_1_to_25100_html",
      id_type: "have_paperwork",
      doc_type: "all_copies_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 3,
        TaxReturn.current_tax_year - 2,
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['none_of_the_above'],
      assistance_options: ['none_of_the_above']
    )
    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageAssistanceController,
      Questions::TriageReferralController,
    ].map(&:to_path_helper))
  end

  scenario "client with 0 income and didn't file in 2021 and did file in 2020 is routed to getctc option" do
    pages = answer_gyr_triage_questions(
      income_level: "zero",
      id_type: "have_paperwork",
      doc_type: "all_copies_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['none_of_the_above']
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageExpressController,
    ].map(&:to_path_helper))
  end

  scenario "client filing for just 2021 with lowest non-zero income and says tax docs don't apply to them is routed to getctc option" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_1_to_25100_html",
      id_type: "have_paperwork",
      doc_type: "does_not_apply_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 3,
        TaxReturn.current_tax_year - 2,
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['none_of_the_above'],
      assistance_options: ['none_of_the_above'],
    )

    expect(pages).to eq([
                          Questions::TriageIncomeLevelController,
                          Questions::TriageStartIdsController,
                          Questions::TriageIdTypeController,
                          Questions::TriageDocTypeController,
                          Questions::TriageBacktaxesYearsController,
                          Questions::TriageAssistanceController,
                          Questions::TriageIncomeTypesController,
                          Questions::TriageExpressController,
                        ].map(&:to_path_helper))
  end

  scenario "client with income above 0 and does not have tax documents is routed to getctc option" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_1_to_25100_html",
      id_type: "have_paperwork",
      doc_type: "need_help_html",
      filed_past_years: [
      ],
      income_type_options: ['none_of_the_above']
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageExpressController,
    ].map(&:to_path_helper))
  end

  scenario "client with IDs and some/all tax docs and within filing limit of 66k and with back taxes and no rental income/farm income is routed to full service" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_25100_to_66000",
      id_type: "have_paperwork",
      doc_type: "all_copies_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['none_of_the_above']
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageGyrController,
    ].map(&:to_path_helper))
  end

  scenario "client with IDs and some/all tax docs and within filing limit of 66k and needing assistance and no rental income/farm income is routed to full service" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_25100_to_66000",
      id_type: "have_paperwork",
      doc_type: "all_copies_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 3,
        TaxReturn.current_tax_year - 2,
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['none_of_the_above'],
      assistance_options: ['in_person', 'phone_review_english', 'phone_review_non_english'],
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageAssistanceController,
      Questions::TriageIncomeTypesController,
      Questions::TriageGyrController,
    ].map(&:to_path_helper))
  end

  scenario "client with IDs and some/all tax docs and within filing limit of 66k and needing assistance and rental or farm income is routed to do not qualify" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_25100_to_66000",
      id_type: "have_paperwork",
      doc_type: "all_copies_html",
      filed_past_years: [
        TaxReturn.current_tax_year - 3,
        TaxReturn.current_tax_year - 2,
        TaxReturn.current_tax_year - 1,
      ],
      income_type_options: ['farm'],
      assistance_options: ['chat'],
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageAssistanceController,
      Questions::TriageIncomeTypesController,
      Questions::TriageReferralController,
    ].map(&:to_path_helper))
  end

  scenario "client needing ITIN assistance within the income limit is routed to full service" do
    pages = answer_gyr_triage_questions(
      income_level: "hh_25100_to_66000",
      id_type: "need_help",
      income_type_options: ['none_of_the_above'],
    )

    expect(pages).to eq([
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageIncomeTypesController,
      Questions::TriageGyrController,
    ].map(&:to_path_helper))
  end
end
