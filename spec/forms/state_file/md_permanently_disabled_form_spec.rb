require "rails_helper"

RSpec.describe StateFile::MdPermanentlyDisabledForm do
  let(:intake) { create :state_file_md_intake, primary_birth_date: primary_dob, spouse_birth_date: spouse_dob }
  let(:form) { described_class.new(intake, params) }
  let(:primary_dob) { nil }
  let(:spouse_dob) { nil }

  describe "#valid?" do
    context "when filing status is MFJ" do
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

      ["primary", "spouse"].each do |filer|
        context "when #{filer} is disabled and not a senior" do
          let(:primary_proof_of_disability_submitted) { "yes" }
          let(:spouse_proof_of_disability_submitted) { "yes" }
          let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
          let(:spouse_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
          let("#{filer}_dob".to_sym) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

          [filer, "both"].each do |mfj_disability|
            context "when mfj_disability is #{mfj_disability}" do
              let(:mfj_disability) { mfj_disability }

              context "#{filer} is senior and did not answer proof question" do
                let("#{filer}_dob".to_sym) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
                let("#{filer}_proof_of_disability_submitted".to_sym) { nil }

                it "is valid" do
                  expect(form).to be_valid
                end
              end

              context "#{filer} is not senior" do
                let("#{filer}_dob".to_sym) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

                context "and answered proof question" do
                  let("#{filer}_proof_of_disability_submitted".to_sym) { "no" }

                  it "is valid" do
                    expect(form).to be_valid
                  end
                end

                context "and did not proof question" do
                  let("#{filer}_proof_of_disability_submitted".to_sym) { nil }

                  it "is not valid" do
                    expect(form).not_to be_valid
                    expect(form.errors["#{filer}_proof_of_disability_submitted".to_sym]).to include "Can't be blank."
                  end
                end
              end
            end
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
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return false
      end

      context "when primary_disabled is blank" do
        let(:params) { { primary_disabled: nil } }

        it "is invalid and attaches the correct error" do
          expect(form).not_to be_valid
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
        end
      end

      context "when primary is a senior" do
        let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }

        context "when proof_of_disability_submitted is blank" do
          let(:params) { { primary_disabled: "yes", primary_proof_of_disability_submitted: nil } }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end

      context "when primary is not a senior" do
        let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }
        let(:params) { { primary_disabled: primary_disabled, primary_proof_of_disability_submitted: primary_proof_of_disability_submitted } }
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return false
        end

        context "when primary_disabled is yes" do
          let(:primary_disabled) { "yes" }

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
end
