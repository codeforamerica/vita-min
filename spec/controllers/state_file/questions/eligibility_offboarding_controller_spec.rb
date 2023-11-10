require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityOffboardingController do
  describe ".show?" do
    context "ny intake" do
      let(:eligibility_lived_in_state) { "yes" }
      let(:eligibility_yonkers) { "no" }
      let(:intake) {
        create :state_file_ny_intake,
               eligibility_lived_in_state: eligibility_lived_in_state,
               eligibility_yonkers: eligibility_yonkers
      }

      context "they are eligible" do
        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "they are not eligible" do
        context "eligibility_lived_in_state is no" do
          let(:eligibility_lived_in_state) { "no" }

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end

        context "eligibility_yonkers is yes" do
          let(:eligibility_yonkers) { "yes" }

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end
      end
    end

    context "az intake" do
      let(:eligibility_lived_in_state) { "yes" }
      let(:eligibility_married_filing_separately) { "no" }
      let(:intake) {
        create :state_file_az_intake,
               eligibility_lived_in_state: eligibility_lived_in_state,
               eligibility_married_filing_separately: eligibility_married_filing_separately
      }

      context "they are eligible" do
        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "they are not eligible" do
        context "eligibility_lived_in_state is no" do
          let(:eligibility_lived_in_state) { "no" }

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end

        context "eligibility_married_filing_separately is yes" do
          let(:eligibility_married_filing_separately) { "yes" }

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end
      end
    end
  end
end