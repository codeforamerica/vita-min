require "rails_helper"

RSpec.describe StateFile::MdHadHealthInsuranceForm do
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

    context "had_hh_member_without_health_insurance is yes" do
      it "is invalid when authorize_sharing_of_health_insurance_info is nil" do
        form = described_class.new(intake, {
          had_hh_member_without_health_insurance: "yes",
          primary_did_not_have_health_insurance: "yes",
          spouse_did_not_have_health_insurance: "no",
          authorize_sharing_of_health_insurance_info: nil
        })
        expect(form.valid?).to eq false
        expect(form.errors[:authorize_sharing_of_health_insurance_info]).to include "Can't be blank."
      end

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
    end
  end

  describe "#save" do
    let(:intake) do
      create(:state_file_md_intake, dependents: [
        create(:state_file_dependent, md_did_not_have_health_insurance: "unfilled"),
        create(:state_file_dependent, md_did_not_have_health_insurance: "unfilled")
      ])
    end
    let(:form) { described_class.new(intake, params) }

    context "params are valid" do
      let(:params) do
        {
          had_hh_member_without_health_insurance: "yes",
          primary_did_not_have_health_insurance: "yes",
          spouse_did_not_have_health_insurance: "no",
          authorize_sharing_of_health_insurance_info: "yes",
          dependents_attributes: {
            "0" => { id: intake.dependents.first.id, md_did_not_have_health_insurance: "yes" },
            "1" => { id: intake.dependents.second.id, md_did_not_have_health_insurance: "no" }
          }
        }
      end

      it "updates the dependents and saves the spouse_did_not_have_health_insurance as 'no'" do
        # Before saving, attributes should reflect initial values
        expect(intake.had_hh_member_without_health_insurance).to eq("unfilled")
        expect(intake.primary_did_not_have_health_insurance).to eq("unfilled")
        expect(intake.spouse_did_not_have_health_insurance).to eq("unfilled")
        expect(intake.authorize_sharing_of_health_insurance_info).to eq("unfilled")
        expect(intake.dependents.first.md_did_not_have_health_insurance).to eq("unfilled")
        expect(intake.dependents.second.md_did_not_have_health_insurance).to eq("unfilled")

        expect(form.valid?).to eq true
        form.save
        intake.reload

        expect(intake.spouse_did_not_have_health_insurance).to eq("no")
        expect(intake.had_hh_member_without_health_insurance).to eq("yes")
        expect(intake.primary_did_not_have_health_insurance).to eq("yes")
        expect(intake.authorize_sharing_of_health_insurance_info).to eq("yes")
        expect(intake.dependents.first.md_did_not_have_health_insurance).to eq("yes")
        expect(intake.dependents.second.md_did_not_have_health_insurance).to eq("no")
      end
    end
  end
end
