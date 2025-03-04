require "rails_helper"

RSpec.describe StateFile::Questions::MdPensionExclusionOffboardingController do
  let(:intake) { create(:state_file_md_intake, :with_spouse) }
  let!(:state_file1099_r) { create(:state_file1099_r, intake: intake) }

  before do
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    context "when they have no 1099Rs in their DF XML" do
      before { allow(intake).to receive(:state_file1099_rs).and_return([]) }

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "not mfj" do
      let(:intake) { create(:state_file_md_intake) }

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when they have 1099Rs in their DF XML" do
      context "when a filer is disabled" do
        before do
          allow(intake).to receive(:filer_disabled?).and_return(true)
        end
        context "has a disabled filer under 65" do
          before do
            allow(intake).to receive(:has_filer_under_65?).and_return(true)
          end

          context "has no proof of disability" do
            before do
              allow(intake).to receive(:no_proof_of_disability_submitted?).and_return(true)
            end

            it "shows" do
              expect(described_class.show?(intake)).to eq true
            end
          end

          context "has proof of disability" do
            before do
              allow(intake).to receive(:no_proof_of_disability_submitted?).and_return(false)
            end

            it "shows" do
              expect(described_class.show?(intake)).to eq false
            end
          end
        end

        context "does not have a filer under 65" do
          before do
            allow(intake).to receive(:has_filer_under_65?).and_return(false)
          end

          context "has no proof of disability" do
            before do
              allow(intake).to receive(:no_proof_of_disability_submitted?).and_return(true)
            end

            it "shows" do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context "has proof of disability" do
            it "shows" do
              expect(described_class.show?(intake)).to eq false
            end
          end
        end
      end

      context "when no filers are disabled" do
        before do
          allow(intake).to receive(:filer_disabled?).and_return(false)
        end

        it "shows" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when the flipper flag is not enabled " do
        before do
          allow(Flipper).to receive(:enabled?).and_call_original
          allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false)
        end

        it "shows" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end
  end
end
