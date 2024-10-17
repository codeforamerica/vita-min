class DirectFileJsonData
  class DfJsonPerson < DfJsonWrapper
    json_reader first_name: { type: :string, key: "firstName" }
    json_reader middle_initial: { type: :string, key: "middleInitial" }
    json_reader last_name: { type: :string, key: "lastName" }
    json_reader dob: { type: :date, key: "dateOfBirth" }
    json_reader tin: { type: :string, key: "tin" }
  end

  class DfJsonFiler < DfJsonPerson
    json_reader is_primary_filer: { type: :boolean, key: "isPrimaryFiler" }
  end

  class DfJsonDependent < DfJsonPerson
    json_reader relationship: { type: :string, key: "relationship" }
    json_reader eligible_dependent: { type: :boolean, key: "eligibleDependent" }
    json_reader is_claimed_dependent: { type: :boolean, key: "isClaimedDependent" }
  end

  class DfJsonInterestReport < DfJsonWrapper
    json_reader amount_1099: { type: :money_amount, key: "1099Amount" }
    json_reader has_1099: { type: :boolean, key: "has1099" }
    json_reader interest_on_government_bonds: { type: :money_amount, key: "interestOnGovernmentBonds" }
    json_reader amount_no_1099: { type: :money_amount, key: "no1099Amount" }
    json_reader recipient_tin: { type: :string, key: "recipientTin" }
    json_reader tax_exempt_interest: { type: :money_amount, key: "taxExemptInterest" }
    json_reader payer: { type: :string, key: "payer" }
    json_reader payer_tin: { type: :string, key: "payerTin" }
    json_reader tax_withheld: { type: :money_amount, key: "taxWithheld" }
    json_reader tax_exempt_and_tax_credit_bond_cusip_number: { type: :string, key: "taxExemptAndTaxCreditBondCusipNo" }
  end

  attr_reader :data

  def initialize(json)
    @data = JSON.parse(json || "{}")
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
    data["interestReports"]&.map { |interest_report| DirectFileJsonData::DfJsonInterestReport.new(interest_report) } || []
  end

  private

  def filers
    data["filers"]&.map { |filer| DirectFileJsonData::DfJsonFiler.new(filer) } || []
  end

  def dependents
    data["familyAndHousehold"]&.map { |dependent| DirectFileJsonData::DfJsonDependent.new(dependent) } || []
  end

end