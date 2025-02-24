require "rails_helper"

RSpec.describe StateFile::MdPermanentlyDisabledForm do
  let(:intake) { create :state_file_md_intake }
  let(:form) { described_class.new(intake, params) }

  describe "#valid?" do
    context "when filing status is MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "when mfj disability status is blank" do
        let(:params) { { mfj_disability: "" } }

        it "is invalid and attaches the correct error" do
          expect(form).not_to be_valid
          expect(form.errors[:mfj_disability]).to include "Can't be blank."
        end
      end

      [:primary, :spouse].each do |filer|
        context "when #{filer} is disabled" do
          let(:mfj_disability_param) { filer == :primary ? "me" : "spouse" }
          let(:disability_param) { "#{filer}_proof_of_disability_submitted".to_sym }

          context "when #{filer} disability status and #{filer} proof of disability submitted is present" do
            let(:params) { { :mfj_disability => mfj_disability_param, disability_param => "yes" } }
            it "is valid" do
              expect(form).to be_valid
            end
          end

          context "when #{filer} proof of disability submitted is required" do
            let(:params) { { :mfj_disability => mfj_disability_param, disability_param => "" } }
            it "is invalid if #{filer}_proof_of_disability_submitted is blank" do
              expect(form).not_to be_valid
              expect(form.errors[disability_param]).to include "Can't be blank."
            end
          end
        end
      end

      context "when both filers are disabled" do
        context "when neither proof of disability is submitted" do
          let(:params) { { mfj_disability: "both" } }
          it "is invalid if both filers proof of disability is blank" do
            expect(form).not_to be_valid
            expect(form.errors[:primary_proof_of_disability_submitted]).to include "Can't be blank."
            expect(form.errors[:spouse_proof_of_disability_submitted]).to include "Can't be blank."
          end
        end

        [:primary, :spouse].each do |filer|
          context "when only the #{filer}'s proof of disability is submitted" do
            let(:params) { { :mfj_disability => "both", "#{filer}_proof_of_disability_submitted".to_sym => "yes" } }
            let(:other_filer) { filer == :primary ? "spouse" : "primary" }

            it "is invalid if both filer's proof of disability is not entered" do
              expect(form).not_to be_valid
              expect(form.errors["#{other_filer}_proof_of_disability_submitted".to_sym]).to include "Can't be blank."
            end
          end
        end

        context "when both filer's proof of disability is submitted" do
          let(:params) { { mfj_disability: "both", primary_proof_of_disability_submitted: "yes", spouse_proof_of_disability_submitted: "yes" } }
          it "is invalid" do
            expect(form).to be_valid
          end
        end

      end
    end

    context "when filing status is not MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return false
      end

      context "when primary_disabled is blank" do
        let(:params) { { primary_disabled: "" } }

        it "is invalid and attaches the correct error" do
          expect(form).not_to be_valid
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
        end
      end

      context "when primary_disabled is present and proof of disability submitted is present" do
        let(:params) { { primary_disabled: "yes", primary_proof_of_disability_submitted: "yes" } }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when primary_disabled is no and proof of disability submitted is not present" do
        let(:params) { { primary_disabled: "no", primary_proof_of_disability_submitted: "" } }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when proof_of_disability_submitted is required" do
        let(:params) { { primary_disabled: "yes", primary_proof_of_disability_submitted: "" } }

        it "is invalid if proof_of_disability_submitted is blank" do
          expect(form).not_to be_valid
          expect(form.errors[:primary_proof_of_disability_submitted]).to include "Can't be blank."
        end
      end
    end
  end

  describe "#save" do
    context "when filing status is MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "when mfj_disability is 'me'" do
        let(:params) { { mfj_disability: "me", primary_proof_of_disability_submitted: "yes" } }

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
end
