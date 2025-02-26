require "rails_helper"

RSpec.describe StateFile::MdPermanentlyDisabledForm do
  let(:intake) { create :state_file_md_intake, primary_birth_date: primary_dob, spouse_birth_date: spouse_dob }
  let(:form) { described_class.new(intake, params) }
  let(:primary_dob) { nil }
  let(:spouse_dob) { nil }

  describe "#valid?" do
    shared_examples :is_invalid do |invalid_params|
      it "has presence error(s)" do
        expect(form).not_to be_valid
        invalid_params.each do |param|
          expect(form.errors[param]).to include "Can't be blank."
        end
      end
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
        let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
        let(:spouse_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
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
        let(:senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
        let(:not_senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

        context "all filers are senior" do
          it "is valid if proof question is not answered" do
            intake.update(primary_birth_date: senior_dob, spouse_birth_date: senior_dob)
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "one or more filers are not senior" do
          context "proof question is not answered" do
            context "primary is not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted]
            end

            context "spouse is not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:primary_dob) { senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted]
            end

            context "both are not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted]
            end
          end

          context "proof question is answered" do
            let(:primary_proof_of_disability_submitted) { "yes" }
            let(:primary_dob) { senior_dob }
            let(:spouse_dob) { senior_dob }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end
      end

      context "when mfj_disability is spouse" do
        let(:mfj_disability) { "spouse" }
        let(:senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
        let(:not_senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

        context "all filers are senior" do
          it "is valid if proof question is not answered" do
            intake.update(primary_birth_date: senior_dob, spouse_birth_date: senior_dob)
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "one or more filers are not senior" do
          context "proof question is not answered" do
            context "primary is not senior" do
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { senior_dob }

              it_behaves_like :is_invalid, [:spouse_proof_of_disability_submitted]
            end

            context "spouse is not senior" do
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:spouse_proof_of_disability_submitted]
            end

            context "both are not senior" do
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:spouse_proof_of_disability_submitted]
            end
          end

          context "proof question is answered" do
            let(:spouse_proof_of_disability_submitted) { "yes" }
            let(:primary_dob) { senior_dob }
            let(:spouse_dob) { senior_dob }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end
      end

      context "when mfj_disability is both" do
        let(:mfj_disability) { "both" }
        let(:senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
        let(:not_senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

        context "all filers are senior" do
          it "is valid if proof question is not answered" do
            intake.update(primary_birth_date: senior_dob, spouse_birth_date: senior_dob)
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
        end

        context "one or more filers are not senior" do
          context "proof question is not answered" do
            context "primary is not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted]
            end

            context "spouse is not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted]
            end

            context "both are not senior" do
              let(:primary_proof_of_disability_submitted) { nil }
              let(:spouse_proof_of_disability_submitted) { nil }
              let(:primary_dob) { not_senior_dob }
              let(:spouse_dob) { not_senior_dob }

              it_behaves_like :is_invalid, [:primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted]
            end
          end

          context "proof question is answered" do
            let(:primary_proof_of_disability_submitted) { "no" }
            let(:spouse_proof_of_disability_submitted) { "yes" }
            let(:primary_dob) { senior_dob }
            let(:spouse_dob) { senior_dob }

            it "is valid" do
              expect(form).to be_valid
            end
          end
        end
      end

      context "when mfj_disability is 'none'" do
        let(:mfj_disability) { "none" }
        let(:primary_proof_of_disability_submitted) { nil }
        let(:spouse_proof_of_disability_submitted) { nil }
        let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }
        let(:spouse_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }

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
        let(:primary_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }
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
