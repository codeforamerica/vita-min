require "rails_helper"

describe StandardDeduction do
  describe ".for" do
    context "for tax years without definition" do
      it "raises NotImplementedError" do
        expect {
          described_class.for(tax_year: 2019, filing_status: "single")
        }.to raise_error NotImplementedError, "Standard deduction rule not implemented for 2019"
      end
    end

    context "when filing status is not provided" do
      it "returns nil" do
        expect(described_class.for(tax_year: 2021, filing_status: nil)).to eq nil
      end
    end

    context "tax_year: 2020" do
      context "filing_status: single" do
        it "is 12400" do
          expect(described_class.for(tax_year: 2020, filing_status: "single")).to eq 12400
        end
      end

      context "filing_status: married_filing_separately" do
        it "is 12400" do
          expect(described_class.for(tax_year: 2020, filing_status: "married_filing_separately")).to eq 12400
        end
      end

      context "filing_status: married_filing_jointly" do
        it "is 24800" do
          expect(described_class.for(tax_year: 2020, filing_status: "married_filing_jointly")).to eq 24800
        end
      end

      context "filing_status: qualifying_widow" do
        it "is 24800" do
          expect(described_class.for(tax_year: 2020, filing_status: "qualifying_widow")).to eq 24800
        end
      end

      context "filing_status: head_of_household" do
        it "is 18650" do
          expect(described_class.for(tax_year: 2020, filing_status: "head_of_household")).to eq 18650
        end
      end
    end

    context "tax_year: 2021" do
      context "filing_status: single" do
        it "is 12550" do
          expect(described_class.for(tax_year: 2021, filing_status: "single")).to eq 12550
        end
      end

      context "filing_status: married_filing_separately" do
        it "is 12550" do
          expect(described_class.for(tax_year: 2021, filing_status: "married_filing_separately")).to eq 12550
        end
      end

      context "filing_status: married_filing_jointly" do
        it "is 25100" do
          expect(described_class.for(tax_year: 2021, filing_status: "married_filing_jointly")).to eq 25100
        end
      end

      context "filing_status: qualifying_widow" do
        it "is 25100" do
          expect(described_class.for(tax_year: 2021, filing_status: "qualifying_widow")).to eq 25100
        end
      end

      context "filing_status: head_of_household" do
        it "is 18800" do
          expect(described_class.for(tax_year: 2021, filing_status: "head_of_household")).to eq 18800
        end
      end
    end
  end
end