require "rails_helper"

describe StandardDeduction do
  shared_examples "standard_deduction" do |tax_year:, filing_status:, primary_older_than_65: nil, spouse_older_than_65: nil, result:|
    context "tax_year=#{tax_year} filing_status=#{filing_status} primary_older_than_65=#{primary_older_than_65.inspect} spouse_older_than_65=#{spouse_older_than_65.inspect}" do
      it "should eq(#{result})" do
        expect(
          described_class.for(tax_year: tax_year, filing_status: filing_status, primary_older_than_65: primary_older_than_65, spouse_older_than_65: spouse_older_than_65)
        ).to eq(result)
      end
    end
  end

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
      let(:tax_year) { 2021 }

      context "filing_status: single" do
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "single", result: 12550
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "single", primary_older_than_65: true, result: (12550+1700)
      end

      context "filing_status: head_of_household" do
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "head_of_household", result: 18800
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "head_of_household", primary_older_than_65: true, result: (18800+1700)
      end

      context "filing_status: married_filing_separately" do
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "married_filing_separately", result: 12550
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "married_filing_separately", primary_older_than_65: true, result: (12550+1350)
      end

      context "filing_status: married_filing_jointly" do
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "married_filing_jointly", result: 25100
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "married_filing_jointly", primary_older_than_65: true, result: (25100+1350)
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "married_filing_jointly", primary_older_than_65: true, spouse_older_than_65: true, result: (25100+1350+1350)
      end

      context "filing_status: qualifying_widow" do
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "qualifying_widow", result: 25100
        it_should_behave_like "standard_deduction", tax_year: 2021, filing_status: "qualifying_widow", primary_older_than_65: true, result: (25100+1350)
      end
    end
  end
end
