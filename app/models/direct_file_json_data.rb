class DfJsonPerson < DfJsonWrapper
  json_reader first_name: { type: :string, key: "firstName" },
              middle_initial: { type: :string, key: "middleInitial" },
              last_name: { type: :string, key: "lastName" },
              dob: { type: :date, key: "dateOfBirth" },
              tin: { type: :string, key: "tin" }
end

class DfJsonFiler < DfJsonPerson
  json_reader is_primary_filer: { type: :boolean, key: "isPrimaryFiler" }
end

class DfJsonDependent < DfJsonPerson
  json_reader relationship: { type: :string, key: "relationship" },
              eligible_dependent: { type: :boolean, key: "eligibleDependent" },
              is_claimed_dependent: { type: :boolean, key: "isClaimedDependent" }
end

class DfJsonInterestReport < DfJsonWrapper
  json_reader amount_1099: { type: :money_amount, key: "1099Amount" },
              has_1099: { type: :boolean, key: "has1099" },
              interest_on_government_bonds: { type: :money_amount, key: "interestOnGovernmentBonds" },
              amount_no_1099: { type: :money_amount, key: "no1099Amount" },
              recipient_tin: { type: :string, key: "recipientTin" },
              tax_exempt_interest: { type: :money_amount, key: "taxExemptInterest" },
              payer: { type: :string, key: "payer" },
              payer_tin: { type: :string, key: "payerTin" },
              tax_withheld: { type: :money_amount, key: "taxWithheld" },
              tax_exempt_and_tax_credit_bond_cusip_number: { type: :string, key: "taxExemptAndTaxCreditBondCusipNo" }
end

class DirectFileJsonData
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
    data["interestReports"]&.map { |interest_report| DfJsonInterestReport.new(interest_report) } || []
  end

  private

  def filers
    data["filers"]&.map { |filer| DfJsonFiler.new(filer) } || []
  end

  def dependents
    data["familyAndHousehold"]&.map { |dependent| DfJsonDependent.new(dependent) } || []
  end

end