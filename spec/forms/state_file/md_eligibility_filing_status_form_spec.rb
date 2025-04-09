require 'rails_helper'

RSpec.describe StateFile::MdEligibilityFilingStatusForm do
  let(:intake) {
    build :state_file_md_intake,
          eligibility_filing_status_mfj: "unfilled",
          eligibility_homebuyer_withdrawal_mfj: "unfilled",
          eligibility_homebuyer_withdrawal: "unfilled",
          eligibility_home_different_areas: "unfilled"
  }

  describe "validations" do
    let(:filing_status_mfj) { nil }
    let(:withdrawal_mfj) { nil }
    let(:home_different_areas) { nil }
    let(:withdrawal) { nil }
    let(:params) {
      {
        eligibility_filing_status_mfj: filing_status_mfj,
        eligibility_homebuyer_withdrawal_mfj: withdrawal_mfj,
        eligibility_home_different_areas: home_different_areas,
        eligibility_homebuyer_withdrawal: withdrawal
      }
    }
    before do
      @form = described_class.new(intake, params)
      @form.valid?
    end

    context "when eligibility_filing_status_mfj is not present" do
      it "should show form error" do
        expect(@form.errors[:eligibility_filing_status_mfj]).to eq ["Can't be blank."]
      end
    end

    context "when eligibility_filing_status_mfj is present" do
      context "when yes" do
        let(:filing_status_mfj) { "yes" }

        context "valid when all required attributes provided" do
          let(:withdrawal_mfj) { "yes" }
          let(:home_different_areas) { "no" }

          it "is valid" do
            expect(@form.errors).to be_empty
          end
        end

        context "invalid when required attributes are missing" do
          it "is invalid" do
            expect(@form.errors[:eligibility_filing_status_mfj]).not_to be_present
            expect(@form.errors[:eligibility_homebuyer_withdrawal_mfj]).to be_present
            expect(@form.errors[:eligibility_home_different_areas]).to be_present
            expect(@form.errors[:eligibility_homebuyer_withdrawal]).not_to be_present
          end
        end
      end

      context "when no" do
        let(:filing_status_mfj) { "no" }

        context "valid when all required attributes provided" do
          let(:withdrawal) { "yes" }

          it "is valid" do
            expect(@form.errors).to be_empty
          end
        end

        context "invalid when required attributes are missing" do
          context "invalid when required attributes are missing" do
            it "is invalid" do
              expect(@form.errors[:eligibility_filing_status_mfj]).not_to be_present
              expect(@form.errors[:eligibility_homebuyer_withdrawal_mfj]).not_to be_present
              expect(@form.errors[:eligibility_home_different_areas]).not_to be_present
              expect(@form.errors[:eligibility_homebuyer_withdrawal]).to be_present
            end
          end
        end
      end

    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_filing_status_mfj: "yes",
        eligibility_homebuyer_withdrawal_mfj: "no",
        eligibility_home_different_areas: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_filing_status_mfj_yes?).to eq true
      expect(intake.eligibility_home_different_areas_no?).to eq true
      expect(intake.eligibility_homebuyer_withdrawal_mfj_no?).to eq true
    end
  end
end
