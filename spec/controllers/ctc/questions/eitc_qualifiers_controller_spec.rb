require "rails_helper"

describe Ctc::Questions::EitcQualifiersController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe ".show?" do
    context "with the feature flag enabled" do
      before do
        Flipper.enable :eitc
      end

      context "when the client is over 24" do
        let(:intake) { create :ctc_intake, primary_birth_date: 25.years.ago.to_date }

        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when the client is under 24" do
        let(:intake) do
          create(
            :ctc_intake,
            client: create(:client, tax_returns: [(create :tax_return, filing_status: "married_filing_jointly")]),
            primary_birth_date: 23.years.ago.to_date,
            exceeded_investment_income_limit: "no"
          )
        end

        context "when the client has a qualifying child" do
          let!(:dependent) { create :qualifying_child, intake: intake }

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end

        context "when the client has no qualifying children" do
          before do
            intake.dependents.destroy_all
          end

          it "returns true" do
            expect(described_class.show?(intake)).to eq true
          end

          context "when the client is already disqualified by investment income" do
            before do
              intake.update(exceeded_investment_income_limit: "yes")
            end

            it "returns false" do
              expect(described_class.show?(intake)).to eq false
            end
          end
        end
      end
    end

    context "with the feature flag disabled" do
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end
