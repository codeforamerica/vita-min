require "rails_helper"

RSpec.describe StateFile::MdSocialSecurityBenefitsForm do
  let(:intake) do
    create :state_file_md_intake, primary_ssb_amount: nil, spouse_ssb_amount: nil
  end

  describe "#save" do
    # df_data_many_w2s has a fed_ssb of 8000
    let(:intake) { create(:state_file_md_intake, :with_spouse, :df_data_many_w2s) }
    let(:params) do
      {
        primary_ssb_amount: "100",
        spouse_ssb_amount: "200"
      }
    end
    let(:form) { described_class.new(intake, params) }

    context "validations" do
      context "with invalid amounts" do
        it "returns false and adds an error to the form" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_ssb_amount]).to include(I18n.t("state_file.questions.md_social_security_benefits.edit.sum_form_error", total_ssb: 8000))
        end
      end

      context "with valid amounts" do
        let(:params) do
          {
            primary_ssb_amount: "1000.0",
            spouse_ssb_amount: "7000.0"
          }
        end

        it "returns true and updates the intake" do
          expect(form.valid?).to eq true
          form.save
          intake.reload
          expect(intake.primary_ssb_amount).to eq 1000.0
          expect(intake.spouse_ssb_amount).to eq 7000.0
        end
      end
    end
  end
end


