class DocumentRequirements
  RULES = [
    DocumentRequirement.new(DocumentTypes::Identity, required: true, accepted_document_types: DocumentTypes::IDENTITY_TYPES, needed_for: %i[primary spouse], offer_doc_help: true) do |intake|
      !ReturningClientExperimentService.new(intake).skip_identity_documents?
    end,
    DocumentRequirement.new(DocumentTypes::SsnItin, required: true, accepted_document_types: DocumentTypes::SECONDARY_IDENTITY_TYPES, needed_for: %i[primary spouse dependents], offer_doc_help: true) do |intake|
      !ReturningClientExperimentService.new(intake).skip_identity_documents?
    end,
    DocumentRequirement.new(DocumentTypes::Employment, required: true, offer_doc_help: true) do |intake|
      intake.had_earned_income? || intake.had_disability_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1095A, required: true, offer_doc_help: true) do |intake|
      intake.bought_marketplace_health_insurance_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1098, required: false) do |intake|
      intake.paid_mortgage_interest_yes? || intake.paid_local_tax_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1098E, required: false) do |intake|
      intake.paid_student_loan_interest_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1098T, required: false) do |intake|
      intake.paid_post_secondary_educational_expenses_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099A, required: false) do |intake|
      intake.had_debt_forgiven_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099B, required: false, offer_doc_help: true) do |intake|
      intake.had_asset_sale_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099C, required: false) do |intake|
      intake.had_debt_forgiven_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099Div, required: false, offer_doc_help: true) do |intake|
      intake.had_interest_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099G, required: false) do |intake|
      intake.had_unemployment_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099Int, required: false) do |intake|
      intake.had_interest_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099R, required: true, offer_doc_help: true) do |intake|
      intake.had_retirement_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099S, required: false) do |intake|
      intake.had_asset_sale_income_yes? || intake.sold_a_home_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form1099Sa, required: false) do |intake|
      intake.had_hsa_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Rrb1099, required: false, offer_doc_help: true) do |intake|
      intake.had_social_security_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Ssa1099, required: false, offer_doc_help: true) do |intake|
      intake.had_social_security_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::Form5498Sa, required: false) do |intake|
      intake.had_hsa_yes?
    end,
    DocumentRequirement.new(DocumentTypes::IraStatement, required: false) do |intake|
      intake.paid_retirement_contributions_yes?
    end,
    DocumentRequirement.new(DocumentTypes::PriorYearTaxReturn, required: false) do |intake|
      intake.had_local_tax_refund_yes? || intake.reported_asset_sale_loss_yes?
    end,
    DocumentRequirement.new(DocumentTypes::CareProviderStatement, required: false) do |intake|
      intake.paid_dependent_care_yes?
    end,
    DocumentRequirement.new(DocumentTypes::PropertyTaxStatement, required: false) do |intake|
      intake.paid_local_tax_yes?
    end,
    DocumentRequirement.new(DocumentTypes::StudentAccountStatement, required: false) do |intake|
      intake.any_students?
    end,
    DocumentRequirement.new(DocumentTypes::W2G, required: false) do |intake|
      intake.had_gambling_income_yes?
    end,
    DocumentRequirement.new(DocumentTypes::IrsIpPinLetter, required: false) do |intake|
      intake.issued_identity_pin_yes? || intake.spouse_issued_identity_pin_yes?
    end,
    DocumentRequirement.new(DocumentTypes::EstimatedTaxReceipts, required: true) do |intake|
      intake.made_estimated_tax_payments_yes? || intake.cv_last_years_refund_applied_to_this_yr_cb_yes?
    end,
    DocumentRequirement.new(DocumentTypes::DirectDepositInformation, required: false) do |intake|
      intake.refund_direct_deposit_yes?
    end,
    DocumentRequirement.new(DocumentTypes::PersonalLedger, required: false) do |intake|
      intake.had_tips_yes?
    end,
  ].freeze

  def self.for_document_type(document_type)
    RULES.find { |rule| rule.document_type == document_type }
  end

  def initialize(intake)
    @intake = intake
  end

  def all
    @all ||= RULES.select { |rule| rule.applies_to?(@intake) }
  end

  def required
    all.select(&:required?)
  end

  def recommended
    all.select(&:recommended?)
  end
end
