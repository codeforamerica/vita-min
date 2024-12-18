class DirectFileJsonData
  class DfJsonPerson < DfJsonWrapper
    json_accessor first_name: { type: :string, key: "firstName" }
    json_accessor middle_initial: { type: :string, key: "middleInitial" }
    json_accessor last_name: { type: :string, key: "lastName" }
    json_accessor suffix: { type: :string, key: "suffix" }
    json_accessor dob: { type: :date, key: "dateOfBirth" }
    json_accessor tin: { type: :string, key: "tin" }
    json_accessor ssn_not_valid_for_employment: { type: :boolean, key: "ssnNotValidForEmployment" }
  end

  class DfJsonFiler < DfJsonPerson
    json_accessor is_primary_filer: { type: :boolean, key: "isPrimaryFiler" }
    json_accessor form_1099_gs_total: { type: :money_amount, key: "form1099GsTotal" }
    json_accessor educator_expenses: { type: :money_amount, key: "educatorExpenses" }
    json_accessor hsa_total_deductible_amount: { type: :money_amount, key: "hsaTotalDeductibleAmount" }
  end

  class DfJsonDependent < DfJsonPerson
    json_accessor relationship: { type: :string, key: "relationship" }
    json_accessor eligible_dependent: { type: :boolean, key: "eligibleDependent" }
    json_accessor is_claimed_dependent: { type: :boolean, key: "isClaimedDependent" }
    json_accessor qualifying_child: { type: :boolean, key: "qualifyingChild" }
    json_accessor hoh_qualifying_person: { type: :boolean, key: 'hohQualifyingPerson' }

    # The numeric field "monthsLivedWithTPInUS" is unreliable, so we use the ranges in "residencyDuration" and translate them into approximate values
    # See Kiteworks: FTA State Exchange System / IRS Direct File / JSON Export Details / Draft IRS Direct File JSON Export Additions.docx
    WORDS_TO_NUMBERS = {
      "allYear" => 12,
      "sixToElevenMonths" => 7,
      "lessThanSixMonths" => 5
    }

    def months_in_home
      number_word = df_json_value(["residencyDuration"])
      return WORDS_TO_NUMBERS[number_word] if number_word
    end

    def months_in_home=(value)
      numbers_to_words = WORDS_TO_NUMBERS.invert
      if value.present? && !numbers_to_words.key?(value)
        raise ArgumentError, "months_in_home must be in #{numbers_to_words.keys}"
      end
      df_json_set(["residencyDuration"], numbers_to_words[value])
    end
  end

  class DfJsonInterestReport < DfJsonWrapper
    json_accessor amount_1099: { type: :money_amount, key: "1099Amount" }
    json_accessor has_1099: { type: :boolean, key: "has1099" }
    json_accessor interest_on_government_bonds: { type: :money_amount, key: "interestOnGovernmentBonds" }
    json_accessor amount_no_1099: { type: :money_amount, key: "no1099Amount" }
    json_accessor recipient_tin: { type: :string, key: "recipientTin" }
    json_accessor tax_exempt_interest: { type: :money_amount, key: "taxExemptInterest" }
    json_accessor payer: { type: :string, key: "payer" }
    json_accessor payer_tin: { type: :string, key: "payerTin" }
    json_accessor tax_withheld: { type: :money_amount, key: "taxWithheld" }
    json_accessor tax_exempt_and_tax_credit_bond_cusip_number: { type: :string, key: "taxExemptAndTaxCreditBondCusipNo" }
  end

  attr_reader :data
  delegate :to_json, to: :data

  def initialize(json)
    @data = json || {}
  end

  def primary_filer
    filers.find(&:is_primary_filer)
  end

  def spouse_filer
    filers.find { |filer| !filer.is_primary_filer }
  end

  def find_matching_json_dependent(dependent)
    dependents.find do |json_dependent|
      next unless json_dependent.present?

      json_tin = json_dependent.tin&.tr("-", "")
      xml_ssn = dependent.ssn

      next unless json_tin && xml_ssn
      json_tin == xml_ssn
    end
  end

  def interest_reports
    data["interestReports"]&.map { |interest_report| DfJsonInterestReport.new(interest_report) } || []
  end

  def filers
    data["filers"]&.map { |filer| DfJsonFiler.new(filer) } || []
  end

  def dependents
    data["familyAndHousehold"]&.map { |dependent| DfJsonDependent.new(dependent) } || []
  end
end
