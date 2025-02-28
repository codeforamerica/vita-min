require "rails_helper"

RSpec.describe StateFile::IdDisabilityForm do
  let(:intake) { create :state_file_id_intake }
  let(:form) { described_class.new(intake, params) }
  let(:senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
  let(:not_senior_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 63), 1, 1) }


  describe "#valid?" do
    let(:primary_birth_date) { not_senior_dob }
    let(:spouse_birth_date) { not_senior_dob }

    before do
      intake.update(primary_birth_date: primary_birth_date)
      intake.update(spouse_birth_date: spouse_birth_date)
    end

    context "when filing status is MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "when both filers are between 62-65" do
        context "when mfj_disability is blank" do
          let(:params) { { mfj_disability: "" } }

          it "is invalid and attaches the correct error" do
            expect(form).not_to be_valid
            expect(form.errors[:mfj_disability]).to include "Can't be blank."
          end
        end

        context "when mfj_disability is present" do
          let(:params) { { mfj_disability: "primary" } }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end

      context "when only primary is between 62-65" do
        let(:primary_birth_date) { not_senior_dob }
        let(:spouse_birth_date) { senior_dob }

        context "when primary_disabled is blank" do
          let(:params) { { primary_disabled: "" } }

          it "is invalid and attaches the correct error" do
            expect(form).not_to be_valid
            expect(form.errors[:primary_disabled]).to include "Can't be blank."
          end
        end

        context "when primary_disabled is not yes/no" do
          let(:params) { { primary_disabled: "invalid" } }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:primary_disabled]).to include "Can't be blank."
          end
        end

        context "when primary_disabled is valid" do
          let(:params) { { primary_disabled: "yes" } }

          it "is valid" do
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

      context "when primary_disabled is not yes/no" do
        let(:params) { { primary_disabled: "invalid" } }

        it "is invalid" do
          expect(form).not_to be_valid
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
        end
      end

      context "when primary_disabled is valid" do
        let(:params) { { primary_disabled: "yes" } }

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end
  end

  describe "#save" do
    let(:intake) { create :state_file_id_intake, :mfj_filer_with_json}
    let!(:primary_1099r) do
      create :state_file1099_r,
             intake: intake,
             recipient_ssn: "400000030"
    end

    let!(:spouse_1099r) do
      create :state_file1099_r,
             intake: intake,
             recipient_ssn: "600000030"
    end

    context "when filing status is MFJ" do
      context "when both filers are 62-65" do
        before do
          intake.update(primary_birth_date: not_senior_dob)
          intake.update(spouse_birth_date: not_senior_dob)
        end

        context "when mfj_disability is 'me'" do
          let(:params) { { mfj_disability: "primary" } }

          it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'no'" do
            form.save
            intake.reload
            expect(intake.primary_disabled).to eq "yes"
            expect(intake.spouse_disabled).to eq "no"
          end

          context "when a followup already exists for spouse no longer disabled" do
            let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: spouse_1099r, eligible_income_source: "yes" }

            it "updates intake using attributes_for" do
              expect do
                form.save
              end.to change(StateFileId1099RFollowup, :count).by(-1)
            end
          end
        end

        context "when mfj_disability is 'spouse'" do
          let(:params) { { mfj_disability: "spouse" } }

          it "updates intake with primary_disabled: 'no' and spouse_disabled: 'yes'" do
            form.save
            intake.reload
            expect(intake.primary_disabled).to eq "no"
            expect(intake.spouse_disabled).to eq "yes"
          end

          context "when a followup already exists and primary no longer disabled" do
            let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: primary_1099r, eligible_income_source: "yes" }

            it "updates intake using attributes_for" do
              expect do
                form.save
              end.to change(StateFileId1099RFollowup, :count).by(-1)
            end
          end
        end

        context "when mfj_disability is 'both'" do
          let(:params) { { mfj_disability: "both" } }

          it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'yes'" do
            form.save
            intake.reload
            expect(intake.primary_disabled).to eq "yes"
            expect(intake.spouse_disabled).to eq "yes"
          end

          context "when a followup already exists" do
            let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: primary_1099r, eligible_income_source: "yes" }
            let!(:spouse_followup) { create :state_file_id1099_r_followup, state_file1099_r: spouse_1099r, eligible_income_source: "yes" }

            it "does not change the number of followups (does not destroy existing followups)" do
              expect do
                form.save
              end.to change(StateFileId1099RFollowup, :count).by(0)
            end
          end
        end

        context "when mfj_disability is 'none'" do
          let(:params) { { mfj_disability: "none" } }

          it "updates intake with primary_disabled: 'no' and spouse_disabled: 'no'" do
            form.save
            intake.reload
            expect(intake.primary_disabled).to eq "no"
            expect(intake.spouse_disabled).to eq "no"
          end

          context "when a followup already exists" do
            let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: primary_1099r, eligible_income_source: "yes" }
            let!(:spouse_followup) { create :state_file_id1099_r_followup, state_file1099_r: spouse_1099r, eligible_income_source: "yes" }

            it "does not change the number of followups (does not destroy existing followups)" do
              expect do
                form.save
              end.to change(StateFileId1099RFollowup, :count).by(-2)
            end
          end
        end
      end

      context "when only primary is 62-65" do
        before do
          intake.update(primary_birth_date: not_senior_dob)
        end
        context "when primary_disabled is set" do
          let(:params) { { primary_disabled: "yes" } }

          it "updates intake using attributes_for" do
            expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
            form.save
          end
        end

        context "when a followup already exists and changes answer to 'no'" do
          let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: primary_1099r, eligible_income_source: "yes" }
          let(:params) { { primary_disabled: "no" } }

          it "updates intake using attributes_for" do
            expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
            expect do
              form.save
            end.to change(StateFileId1099RFollowup, :count).by(-1)
          end
        end
      end

      context "when only spouse is 62-65" do
        before do
          intake.update(spouse_birth_date: not_senior_dob)
        end

        context "when spouse_disabled is set" do
          let(:params) { { spouse_disabled: "yes" } }

          it "updates intake using attributes_for" do
            expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
            form.save
          end
        end

        context "when a followup already exists and changes answer to 'no'" do
          let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: spouse_1099r, eligible_income_source: "yes" }
          let(:params) { { spouse_disabled: "no" } }

          it "updates intake using attributes_for" do
            expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
            expect do
              form.save
            end.to change(StateFileId1099RFollowup, :count).by(-1)
          end
        end
      end
    end

    context "when filing status is not MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return false
      end

      context "when primary_disabled is set" do
        let(:params) { { primary_disabled: "yes" } }

        it "updates intake using attributes_for" do
          expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
          form.save
        end
      end

      context "when a followup already exists and changes answer to 'no'" do
        let!(:followup) { create :state_file_id1099_r_followup, state_file1099_r: primary_1099r, eligible_income_source: "yes" }
        let(:params) { { primary_disabled: "no" } }

        it "updates intake using attributes_for" do
          expect(intake).to receive(:update).with(form.send(:attributes_for, :intake))
          expect do
            form.save
          end.to change(StateFileId1099RFollowup, :count).by(-1)
        end
      end
    end
  end
end
