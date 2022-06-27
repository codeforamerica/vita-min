require "rails_helper"

describe StandardDeductions do
  describe "#base_deductions" do
    it "retrieves a hash of base deduction amounts for the given year" do
      expect(described_class.base_deductions(tax_year: 2021)).to eq({
        "single" => 12550,
        "married_filing_separately" => 12550,
        "head_of_household" => 18800,
        "married_filing_jointly" => 25100,
        "qualifying_widow" => 25100
                                                                    })
    end

    it "allows access of the hash with string or symbol keys" do
      expect(described_class.base_deductions(tax_year: 2021)[:single]).to eq described_class.base_deductions(tax_year: 2021)["single"]
    end

    context "client's home location is puerto rico" do
      it "retrieves a hash of base deductions for the given year and for Puerto Rican clients" do
        expect(described_class.base_deductions(tax_year: 2021, puerto_rico_filing: true)).to eq({
          "single" => 75000,
          "married_filing_separately" => 75000,
          "head_of_household" => 112500,
          "married_filing_jointly" => 150000,
          "qualifying_widow" => 150000
                                                                    })
      end
    end
  end

  describe "#blind_deductions" do
    it "retrieves a hash of blind deduction amounts for the given year" do
      expect(described_class.blind_deductions(tax_year: 2021)).to eq({
                                                                      "single_filer" => 1700,
                                                                      "primary_or_spouse" => 1350,
                                                                      "primary_and_spouse" => 2700
                                                                    })
    end
  end

  describe "#older_than_65_deductions" do
    it "retrieves a hash of age deduction amounts for the given year" do
      expect(described_class.older_than_65_deductions(tax_year: 2021)).to eq({
                                                                      "single_filer" => 1700,
                                                                      "primary_or_spouse" => 1350,
                                                                      "primary_and_spouse" => 2700
                                                                    })
    end
  end
end
