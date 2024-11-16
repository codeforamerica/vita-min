class DirectFileJsonData
  class DfJsonPerson < DfJsonWrapper
    json_accessor first_name: { type: :string, key: "firstName" }
    json_accessor middle_initial: { type: :string, key: "middleInitial" }
    json_accessor last_name: { type: :string, key: "lastName" }
    json_accessor dob: { type: :date, key: "dateOfBirth" }
    json_accessor tin: { type: :string, key: "tin" }
  end

  class DfJsonFiler < DfJsonPerson
    json_accessor is_primary_filer: { type: :boolean, key: "isPrimaryFiler" }
  end

  class DfJsonDependent < DfJsonPerson
    json_accessor relationship: { type: :string, key: "relationship" }
    json_accessor eligible_dependent: { type: :boolean, key: "eligibleDependent" }
    json_accessor is_claimed_dependent: { type: :boolean, key: "isClaimedDependent" }
    json_accessor qualifying_child: { type: :boolean, key: "qualifyingChild" }
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