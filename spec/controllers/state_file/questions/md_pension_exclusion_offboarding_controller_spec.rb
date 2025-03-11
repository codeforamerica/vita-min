require "rails_helper"

RSpec.describe StateFile::Questions::MdPensionExclusionOffboardingController do

  describe "#show?" do
    [:single, :married_filing_jointly].each do |filing_status|
      context "filing status #{filing_status}" do
        context "when all conditions are met" do
          let(:intake) { create(:state_file_md_intake) }
          let!(:state_file1099_r) { create(:state_file1099_r, intake: intake) }

          before do
            allow(Flipper).to receive(:enabled?).and_call_original
            allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)

            allow(intake).to receive(:filing_status).and_return(filing_status)
            allow(intake).to receive(:filer_disabled?).and_return(true)
            allow(intake).to receive(:has_filer_under_65?).and_return(true)
            allow(intake).to receive(:no_proof_of_disability_submitted?).and_return(true)
          end

          it "shows" do
            expect(described_class.show?(intake)).to eq true
          end

          context "except the flipper flag is not set to true" do
            before { allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false) }

            it "does not show" do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context "except filer is not disabled" do
            before { allow(intake).to receive(:filer_disabled?).and_return(false) }

            it "does not show" do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context "except no filer is under 65" do
            before { allow(intake).to receive(:has_filer_under_65?).and_return(false) }

            it "does not show" do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context "except proof of disability has been submitted for all disabled filers" do
            before { allow(intake).to receive(:no_proof_of_disability_submitted?).and_return(false) }

            it "does not show" do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context "except there are no 1099-Rs" do
            before { allow(intake).to receive(:state_file1099_rs).and_return([]) }

            it "does not show" do
              expect(described_class.show?(intake)).to eq false
            end
          end
        end
      end
    end
  end
end
