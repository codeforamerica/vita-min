require "rails_helper"

RSpec.describe StateFile::MdHealthcareScreenForm do
  let(:intake) { create :state_file_md_intake }

  describe "validations" do
    context "had_hh_member_without_health_insurance is nil" do
      it "is invalid" do
        form = described_class.new(intake, {
          had_hh_member_without_health_insurance: nil
        })
        expect(form.valid?).to eq false
        expect(form.errors[:had_hh_member_without_health_insurance]).to include "Can't be blank."
      end
    end

    context "had_hh_member_without_health_insurance is no" do
      it "is valid" do
        form = described_class.new(intake, {
          had_hh_member_without_health_insurance: "no"
        })
        expect(form.valid?).to eq true
      end
    end

    context "had_hh_member_without_health_insurance" do
      it "is invalid when authorize_sharing_of_health_insurance_info is nil" do
        form = described_class.new(intake, {
          had_hh_member_without_health_insurance: "yes",
          primary_did_not_have_health_insurance: "yes",
          spouse_did_not_have_health_insurance: "no",
          authorize_sharing_of_health_insurance_info: nil
        })
        expect(form.valid?).to eq false
      end

      context "when sharing of health insurance info is authorized" do
        context "when had_hh_member_without_health_insurance is yes" do
          context "when dependents are present" do
            let(:intake) do
              create(:state_file_md_intake, dependents: [
                create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
                create(:state_file_dependent, md_did_not_have_health_insurance: "no")
              ])
            end

            it "is invalid when all of the family members have health insurance" do
              form = described_class.new(intake, {
                had_hh_member_without_health_insurance: "yes",
                primary_did_not_have_health_insurance: "no",
                spouse_did_not_have_health_insurance: "no",
                authorize_sharing_of_health_insurance_info: "yes"
              })

              expect(form.valid?).to eq false
              expect(form.errors[:household_health_insurance]).to include(I18n.t("forms.errors.healthcare.one_box"))
            end

            it "is valid when only a dependent does not have health insurance" do
              intake.dependents.first.update!(md_did_not_have_health_insurance: "yes")
              intake.dependents.last.update!(md_did_not_have_health_insurance: "no")

              form = described_class.new(intake, {
                had_hh_member_without_health_insurance: "yes",
                primary_did_not_have_health_insurance: "no",
                spouse_did_not_have_health_insurance: "no",
                authorize_sharing_of_health_insurance_info: "yes"
              })

              expect(form.valid?).to eq true
            end
          end

          it "is valid when a family member is selected" do
            form = described_class.new(intake, {
              had_hh_member_without_health_insurance: "yes",
              primary_did_not_have_health_insurance: "yes",
              spouse_did_not_have_health_insurance: "no",
              authorize_sharing_of_health_insurance_info: "yes"
            })
            expect(form.valid?).to eq true
          end

          it "is invalid when no family member is selected" do
            form = described_class.new(intake, {
              had_hh_member_without_health_insurance: "yes",
              primary_did_not_have_health_insurance: "no",
              spouse_did_not_have_health_insurance: "no",
              authorize_sharing_of_health_insurance_info: "yes"
            })
            expect(form.valid?).to eq false
          end
        end
      end
    end
  end
end
