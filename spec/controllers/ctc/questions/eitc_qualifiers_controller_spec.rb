require "rails_helper"

describe Ctc::Questions::EitcQualifiersController do
  let(:primary_age_at_end_of_tax_year) { 25.years }
  let(:spouse_age_at_end_of_tax_year) { 25.years }
  let(:exceeded_investment_income_limit) { "no" }

  let(:intake) do
    create(
      :ctc_intake,
      client: create(:client, tax_returns: [(create :tax_return, filing_status: "married_filing_jointly")]),
      primary_birth_date: Date.new(MultiTenantService.new(:ctc).current_tax_year, 12, 31) - primary_age_at_end_of_tax_year,
      spouse_birth_date: Date.new(MultiTenantService.new(:ctc).current_tax_year, 12, 31) - spouse_age_at_end_of_tax_year,
      exceeded_investment_income_limit: exceeded_investment_income_limit
    )
  end

  before do
    sign_in intake.client
  end

  describe ".show?" do
    context "with the feature flag enabled" do
      before do
        Flipper.enable :eitc
      end

      context "when the client is over 24" do
        let(:primary_age_at_end_of_tax_year) { 25.years }

        it "returns false" do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end

      context "when the spouse is over 24" do
        let(:primary_age_at_end_of_tax_year) { 23.years }
        let(:spouse_age_at_end_of_tax_year) { 25.years }

        it "returns false" do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end

      context "when the client and spouse are under 24" do
        let(:primary_age_at_end_of_tax_year) { 23.years }
        let(:spouse_age_at_end_of_tax_year) { 23.years }

        context "when the client has a qualifying child" do
          let!(:dependent) { create :qualifying_child, intake: intake }

          it "returns false" do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end

        context "when the client has no qualifying children" do
          it "returns true" do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end

        context "when the client is already disqualified by investment income" do
          let(:exceeded_investment_income_limit) { "yes" }

          it "returns false" do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end
      end
    end

    context "with the feature flag disabled" do
      it "returns false" do
        expect(described_class.show?(intake, subject)).to eq false
      end
    end
  end
end
