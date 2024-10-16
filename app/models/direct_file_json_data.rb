class DfJsonPerson < DfJsonWrapper
  def self.selectors = {
    first_name: { type: :string, key: "firstName" },
    middle_initial: { type: :string, key: "middleInitial" },
    last_name: { type: :string, key: "lastName" },
    dob: { type: :date, key: "dateOfBirth" }
  }

  define_json_readers
end

class DfJsonFiler < DfJsonPerson
  def self.selectors = super.merge({
    is_primary_filer: { type: :boolean, key: "isPrimaryFiler" }
  })

  define_json_readers
end

class DfJsonDependent < DfJsonPerson
  def self.selectors = super.merge({
    relationship: { type: :string, key: "relationship" },
    eligible_dependent: { type: :boolean, key: "eligibleDependent" },
    is_claimed_dependent: { type: :boolean, key: "isClaimedDependent" }
  })

  define_json_readers
end

class DfJsonInterestReport < DfJsonWrapper
  def self.selectors = {
    amount_1099: { type: :money_amount, key: "1099Amount" },
    has_1099: { type: :boolean, key: "has1099" },
    interest_on_government_bonds: { type: :money_amount, key: "interestOnGovernmentBonds" },
    amount_no_1099: { type: :money_amount, key: "no1099Amount" },
    recipient_tin: { type: :string, key: "recipientTin" },
    tax_exempt_interest: { type: :money_amount, key: "taxExemptInterest" },
    payer: { type: :string, key: "payer" },
    payer_tin: { type: :string, key: "payerTin" },
    tax_withheld: { type: :money_amount, key: "taxWithheld" },
    tax_exempt_and_tax_credit_bond_cusip_number: { type: :string, key: "taxExemptAndTaxCreditBondCusipNo" }
  }

  define_json_readers
end

class DirectFileJsonData

  def initialize(json)
    @json = JSON.parse(json || "{}")
  end

  def primary_filer
    filers.find(&:is_primary_filer)
  end

  def spouse_filer
    filers.find { |filer| !filer.is_primary_filer }
  end

  def find_matching_json_dependent(dependent)
    dependents.find do |json_dependent|
      # TODO: find match based on SSN
      json_dependent.first_name == dependent.first_name
    end
  end

  def interest_reports
    @json["interestReports"]&.map { |interest_report| DfJsonInterestReport.new(interest_report) } || []
  end

  private

  def filers
    @json["filers"]&.map { |filer| DfJsonFiler.new(filer)} || []
  end

  def dependents
    @json["familyAndHousehold"]&.map { |dependent| DfJsonDependent.new(dependent)} || []
  end

end