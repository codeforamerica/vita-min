require "rails_helper"

RSpec.describe StateFile::IdDisabilityForm do
  let(:intake) { create :state_file_id_intake }
  let(:form) { described_class.new(intake, params) }

  describe "#valid?" do
    context "when filing status is MFJ" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "when mfj_disability is blank" do
        let(:params) { { mfj_disability: "" } }

        it "is invalid and attaches the correct error" do
          expect(form).not_to be_valid
          expect(form.errors[:mfj_disability]).to include "Can't be blank."
        end
      end

      context "when mfj_disability is present" do
        let(:params) { { mfj_disability: "me" } }

        it "is valid" do
          expect(form).to be_valid
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
             recipient_ssn: "400000030",
             taxable_amount: 1111
    end

    let!(:spouse_1099r) do
      create :state_file1099_r,
             intake: intake,
             recipient_ssn: "600000030",
             taxable_amount: 2222
    end

    context "when filing status is MFJ and both spouse and filer are eligible" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 62, 1, 1)
        intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 62, 1, 1)
      end

      context "when mfj_disability is 'me'" do
        let(:params) { { mfj_disability: "me" } }

        it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'no'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "yes"
          expect(intake.spouse_disabled).to eq "no"
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
      end

      context "when mfj_disability is 'both'" do
        let(:params) { { mfj_disability: "both" } }

        it "updates intake with primary_disabled: 'yes' and spouse_disabled: 'yes'" do
          form.save
          intake.reload
          expect(intake.primary_disabled).to eq "yes"
          expect(intake.spouse_disabled).to eq "yes"
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
    end
  end
end
