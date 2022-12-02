require "rails_helper"

describe AppliedStandardDeduction do
  shared_examples "applied_standard_deduction" do |tax_year:, filing_status:, result:|
    context "tax_year=#{tax_year} filing_status=#{filing_status}}" do
      let(:tax_return) { create(:tax_return, filing_status: filing_status, year: tax_year) }
      it "should eq(#{result})" do
        expect(described_class.new(tax_return: tax_return).applied_standard_deduction).to eq(result)
      end
    end
  end

  describe "#applied_standard_deduction" do
    context "for tax years without definition" do
      let(:tax_return) { create(:tax_return, filing_status: "single", year: 2019) }
      it "raises NotImplementedError" do
        expect {
          described_class.new(tax_return: tax_return).applied_standard_deduction
        }.to raise_error NotImplementedError, "Standard deduction rule not implemented for 2019"
      end
    end

    context "tax_year: 2020" do
      context "filing_status: single" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2020, filing_status: "single", result: 12400
      end

      context "filing_status: married_filing_separately" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2020, filing_status: "married_filing_separately", result: 12400
      end

      context "filing_status: married_filing_jointly" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2020, filing_status: "married_filing_jointly", result: 24800
      end

      context "filing_status: qualifying_widow" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2020, filing_status: "qualifying_widow", result: 24800
      end

      context "filing_status: head_of_household" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2020, filing_status: "head_of_household", result: 18650
      end
    end

    context "tax_year: 2021" do
      let(:tax_year) { 2021 }

      context "filing_status: single" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2021, filing_status: "single", result: 12550
      end

      context "filing_status: head_of_household" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2021, filing_status: "head_of_household", result: 18800
      end

      context "filing_status: married_filing_separately" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2021, filing_status: "married_filing_separately", result: 12550
      end

      context "filing_status: married_filing_jointly" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2021, filing_status: "married_filing_jointly", result: 25100
      end

      context "filing_status: qualifying_widow" do
        it_should_behave_like "applied_standard_deduction", tax_year: 2021, filing_status: "qualifying_widow", result: 25100
      end
    end
  end

  describe "additional blind deduction" do
    let(:tax_return) { create :tax_return, year: 2021, filing_status: filing_status, client: create(:client, intake: create(:intake, was_blind: was_blind, spouse_was_blind: spouse_was_blind)) }
    let(:filing_status) { "single" }
    let(:was_blind) { "yes" }
    let(:spouse_was_blind) { "no" }

    before do
      # remove base amounts in order to test blind addition in isolation
      allow(StandardDeductions).to receive(:base_deductions).with(tax_year: tax_return.year).and_return(
        {
          single: 0,
          married_filing_jointly: 0,
          married_filing_separately: 0,
          qualifying_widow: 0,
          head_of_household: 0
        }.with_indifferent_access
      )
    end

    context "filing status single" do
      let(:filing_status) { "single" }

      context "the primary filer is blind" do
        let(:was_blind) { "yes" }
        it "is 1700" do
          expect(described_class.new(tax_return: tax_return).applied_standard_deduction).to eq 1700
        end
      end

      context "the primary filer is not blind" do
        let(:was_blind) { "no" }
        it "is 0" do
          expect(tax_return.standard_deduction).to eq 0
        end
      end
    end

    context "the primary filer is blind and filing status is head of household" do
      let(:filing_status) { "head_of_household" }

      it "is 1700" do
        expect(tax_return.standard_deduction).to eq 1700
      end
    end

    context "the primary filer and spouse is blind and filing status is married_filing_jointly" do
      let(:filing_status) { "married_filing_jointly" }
      let(:spouse_was_blind) { "yes" }

      it "is 2700" do
        expect(tax_return.standard_deduction).to eq 2700
      end
    end

    context "the primary filer is blind and spouse is not and filing status is married_filing_jointly" do
      let(:filing_status) { "married_filing_jointly" }
      let(:was_blind) { "yes" }
      let(:spouse_was_blind) { "no" }

      it "is 1350" do
        expect(tax_return.standard_deduction).to eq 1350
      end
    end

    context "filing status is a generally unsupported status in GetCTC and primary is blind" do
      let(:filing_status) { "qualifying_widow" }
      let(:was_blind) { "yes" }

      it "is 0" do
        expect(tax_return.standard_deduction).to eq 0
      end
    end

    context "filing status is married_filing_jointly and primary and spouse are not blind" do
      let(:filing_status) { "married_filing_jointly" }
      let(:was_blind) { "no" }
      let(:spouse_was_blind) { "no" }

      it "is 0" do
        expect(tax_return.standard_deduction).to eq 0
      end
    end
  end

  describe "additional age deduction" do
    let(:tax_return) { create :tax_return, filing_status: filing_status, client: create(:client, intake: create(:intake, primary_birth_date: primary_birth_date, spouse_birth_date: spouse_birth_date)) }
    let(:filing_status) { "single" }
    let(:primary_birth_date) { younger_than_65 }
    let(:spouse_birth_date) { younger_than_65 }
    let(:older_than_65) { Date.new(2021 - 64, 1, 1) }
    let(:younger_than_65) { Date.new(2021 - 64, 1, 2) }

    before do
      # remove base amounts in order to test age addition in isolation
      allow(StandardDeductions).to receive(:base_deductions).with(tax_year: tax_return.year).and_return(
        {
          single: 0,
          married_filing_jointly: 0,
          married_filing_separately: 0,
          qualifying_widow: 0,
          head_of_household: 0
        }.with_indifferent_access
      )
    end

    context "filing status is single and primary is older than 65" do
      let(:filing_status) { "single" }
      let(:primary_birth_date) { older_than_65 }

      it "is 1700" do
        expect(tax_return.standard_deduction).to eq 1700
      end
    end

    context "filing status is head_of_household and primary is older than 65" do
      let(:filing_status) { "head_of_household" }
      let(:primary_birth_date) { older_than_65 }

      it "is 1700" do
        expect(tax_return.standard_deduction).to eq 1700
      end
    end

    context "filing status is married_filing_jointly and primary is older than 65 and spouse is younger than 65" do
      let(:filing_status) { "married_filing_jointly" }
      let(:primary_birth_date) { older_than_65 }

      it "is 1350" do
        expect(tax_return.standard_deduction).to eq 1350
      end
    end

    context "filing status is married_filing_jointly and primary is younger than 65 and spouse is older than 65" do
      let(:filing_status) { "married_filing_jointly" }
      let(:spouse_birth_date) { older_than_65 }

      it "is 1350" do
        expect(tax_return.standard_deduction).to eq 1350
      end
    end

    context "filing status is married_filing_jointly and primary is older than 65 and spouse is older than 65" do
      let(:filing_status) { "married_filing_jointly" }
      let(:primary_birth_date) { older_than_65 }
      let(:spouse_birth_date) { older_than_65 }

      it "is 2700" do
        expect(tax_return.standard_deduction).to eq 2700
      end
    end
  end
end
