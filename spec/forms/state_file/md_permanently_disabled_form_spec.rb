require "rails_helper"

RSpec.describe StateFile::MdPermanentlyDisabledForm do
  let(:intake) { create :state_file_md_intake }
  let(:form) { described_class.new(intake, params) }

  describe "#valid?" do
    shared_examples :is_invalid do |invalid_params|
      it "has presence error(s)" do
        expect(form).not_to be_valid
        invalid_params.each do |param|
          expect(form.errors[param]).to include "Can't be blank."
        end
      end
    end

    context "when should warn about pension exclusion" do
      before do
        allow(intake).to receive(:should_warn_about_pension_exclusion?).and_return true
      end
      context "when filing status is MFJ" do
        let(:spouse_proof_of_disability_submitted) { nil }
        let(:primary_proof_of_disability_submitted) { nil }
        let(:params) do
          {
            mfj_disability: mfj_disability,
            primary_proof_of_disability_submitted: primary_proof_of_disability_submitted,
            spouse_proof_of_disability_submitted: spouse_proof_of_disability_submitted
          }
        end
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return true
        end

        context "when mfj_disability status is blank" do
          let(:primary_proof_of_disability_submitted) { nil }
          let(:spouse_proof_of_disability_submitted) { nil }
          let(:mfj_disability) { nil }

          it "is invalid and attaches the correct error" do
            expect(form).not_to be_valid
            expect(form.errors[:mfj_disability]).to include "Can't be blank."
          end
        end

        context "when mfj_disability is primary" do
          let(:mfj_disability) { "primary" }

          context "proof question is not answered" do
            it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted]
          end

          context "proof question is answered" do
            let(:primary_proof_of_disability_submitted) { "yes" }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end

        context "when mfj_disability is spouse" do
          let(:mfj_disability) { "spouse" }

          context "proof question is not answered" do
            it_behaves_like :is_invalid, [:spouse_proof_of_disability_submitted]
          end

          context "proof question is answered" do
            let(:spouse_proof_of_disability_submitted) { "yes" }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end

        context "when mfj_disability is both" do
          let(:mfj_disability) { "both" }

          context "proof question is not answered" do
            it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted]
          end

          context "proof question is answered" do
            let(:primary_proof_of_disability_submitted) { "no" }
            let(:spouse_proof_of_disability_submitted) { "yes" }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end

        context "when mfj_disability is 'none'" do
          let(:mfj_disability) { "none" }
          let(:primary_proof_of_disability_submitted) { nil }
          let(:spouse_proof_of_disability_submitted) { nil }

          it "does not require proof of disability" do
            expect(form).to be_valid
          end
        end
      end

      context "when filing status is not MFJ" do
        let(:params) do
          {
            primary_disabled: primary_disabled,
            primary_proof_of_disability_submitted: primary_proof_of_disability_submitted
          }
        end
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return false
        end

        context "when primary_disabled is blank" do
          let(:primary_disabled) {nil}
          let(:primary_proof_of_disability_submitted) {nil}

          it "is invalid and attaches the correct error" do
            expect(form).not_to be_valid
            expect(form.errors[:primary_disabled]).to include "Can't be blank."
          end
        end

        context "when primary_disabled is yes" do
          let(:primary_disabled)  { "yes" }

          context "proof of disability submitted is present" do
            let(:primary_proof_of_disability_submitted) { "no" }

            it "is valid" do
              expect(form).to be_valid
            end
          end

          context "proof of disability submitted is not present" do
            let(:primary_proof_of_disability_submitted) { nil }

            it "is not valid" do
              expect(form).not_to be_valid
              expect(form.errors[:primary_proof_of_disability_submitted]).to include "Can't be blank."
            end
          end
        end

        context "when primary_disabled is no and proof of disability submitted is not present" do
          let(:params) { { primary_disabled: "no", primary_proof_of_disability_submitted: nil } }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end

    context "when should not warn about pension exclusion" do
      before do
        allow(intake).to receive(:should_warn_about_pension_exclusion?).and_return false
      end
      context "when filing status is MFJ" do
        let(:spouse_proof_of_disability_submitted) { nil }
        let(:primary_proof_of_disability_submitted) { nil }
        let(:params) do
          {
            mfj_disability: mfj_disability,
            primary_proof_of_disability_submitted: primary_proof_of_disability_submitted,
            spouse_proof_of_disability_submitted: spouse_proof_of_disability_submitted
          }
        end
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return true
        end

        context "when mfj_disability is primary" do
          let(:mfj_disability) { "primary" }

          it "is valid if proof question is not answered" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "when mfj_disability is spouse" do
          let(:mfj_disability) { "spouse" }

          it "is valid if proof question is not answered" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "when mfj_disability is both" do
          let(:mfj_disability) { "both" }

          it "is valid if proof question is not answered" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "when mfj_disability is nil" do
          let(:mfj_disability) { nil }

          it "is valid if proof question is not answered" do
            form = described_class.new(intake, params)
            expect(form).to_not be_valid
            expect(form.errors[:mfj_disability]).to include "Can't be blank."
          end
        end
      end

      context "when filing status is not MFJ" do
        let(:params) do
          {
            primary_disabled: primary_disabled,
            primary_proof_of_disability_submitted: primary_proof_of_disability_submitted
          }
        end
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return false
        end

        context "when proof_of_disability_submitted is blank" do
          let(:primary_disabled) { "yes" }
          let(:primary_proof_of_disability_submitted) { nil }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when primary_disabled is blank" do
          let(:primary_disabled) { nil }
          let(:primary_proof_of_disability_submitted) { nil }

          it "is invalid" do
            expect(form).not_to be_valid
          end
        end
      end
    end
  end

  describe "#save" do
    context "when filing status is MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "when mfj_disability is primary" do
        let(:params) { { mfj_disability: "primary", primary_proof_of_disability_submitted: "yes" } }

        it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'no'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "yes"
          expect(intake.spouse_disabled).to eq "no"
          expect(intake.primary_proof_of_disability_submitted).to eq "yes"
          expect(intake.spouse_proof_of_disability_submitted).to eq "unfilled"
        end
      end

      context "when mfj_disability is 'spouse'" do
        let(:params) { { mfj_disability: "spouse", spouse_proof_of_disability_submitted: "no" } }

        it "updates intake with primary_disabled: 'no' and spouse_disabled: 'yes'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "no"
          expect(intake.spouse_disabled).to eq "yes"
          expect(intake.primary_proof_of_disability_submitted).to eq "unfilled"
          expect(intake.spouse_proof_of_disability_submitted).to eq "no"
        end
      end

      context "when mfj_disability is 'both'" do
        let(:params) { { mfj_disability: "both", primary_proof_of_disability_submitted: "no", spouse_proof_of_disability_submitted: "yes" } }

        it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'yes'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "yes"
          expect(intake.spouse_disabled).to eq "yes"
          expect(intake.primary_proof_of_disability_submitted).to eq "no"
          expect(intake.spouse_proof_of_disability_submitted).to eq "yes"
        end
      end

      context "when mfj_disability is 'none'" do
        let(:params) { { mfj_disability: "none" } }

        it "updates intake with primary_disabled: 'no', spouse_disabled: 'no', and clears proof_of_disability_submitted" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "no"
          expect(intake.spouse_disabled).to eq "no"
          expect(intake.primary_proof_of_disability_submitted).to eq "unfilled"
          expect(intake.spouse_proof_of_disability_submitted).to eq "unfilled"
        end
      end
    end

    context "when filing status is not MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return false
      end

      context "when primary_disabled is 'no'" do
        let(:params) { { primary_disabled: "no" } }

        it "updates intake with primary_disabled: 'no' and clears proof_of_disability_submitted" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "no"
          expect(intake.primary_proof_of_disability_submitted).to eq "unfilled"
        end
      end

      context "when primary_disabled is 'yes'" do
        let(:params) { { primary_disabled: "yes", primary_proof_of_disability_submitted: "yes" } }

        it "updates intake with primary_disabled: 'yes' and proof_of_disability_submitted: 'yes'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "yes"
          expect(intake.primary_proof_of_disability_submitted).to eq "yes"
        end
      end
    end
  end

  describe "#existing_attributes" do
    let(:primary_disabled) { "unfilled" }
    let(:spouse_disabled) { "unfilled" }
    let(:form) { described_class.new(intake, {})}
    let(:existing_attributes) { StateFile::MdPermanentlyDisabledForm.existing_attributes(intake) }

    before do
      intake.update(primary_disabled: primary_disabled, spouse_disabled: spouse_disabled)
    end

    context "unfilled" do
      it "does not set mfj_disability on the form" do
        expect(existing_attributes[:mfj_disability]).to eq nil
      end
    end

    context "primary_disabled" do
      let(:primary_disabled) { "yes" }
      let(:spouse_disabled) { "no" }

      it "sets mfj_disability to primary" do
        expect(existing_attributes[:mfj_disability]).to eq "primary"
      end
    end

    context "spouse_disabled" do
      let(:primary_disabled) { "no" }
      let(:spouse_disabled) { "yes" }

      it "sets mfj_disability to spouse" do
        expect(existing_attributes[:mfj_disability]).to eq "spouse"
      end
    end

    context "both disabled" do
      let(:primary_disabled) { "yes" }
      let(:spouse_disabled) { "yes" }

      it "sets mfj_disability to both" do
        expect(existing_attributes[:mfj_disability]).to eq "both"
      end
    end

    context "none disabled" do
      let(:primary_disabled) { "no" }
      let(:spouse_disabled) { "no" }

      it "sets mfj_disability to none" do
        expect(existing_attributes[:mfj_disability]).to eq "none"
      end
    end
  end
end
