require "rails_helper"

RSpec.describe StateFile::NjCollegeDependentsExemptionForm do

  describe "#save" do
    let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
    let(:first_dependent) { intake.dependents[0] }
    let(:second_dependent) { intake.dependents[1] }

    let(:valid_params) do
      {
        dependents_attributes: {
          '0': {
            id: first_dependent.id,
            nj_dependent_attends_accredited_program: "yes",
            nj_dependent_enrolled_full_time: "no",
            nj_dependent_five_months_in_college: "no",
            nj_filer_pays_tuition_for_dependent: "yes"
          },
          '1': {
            id: second_dependent.id,
            nj_dependent_attends_accredited_program: "yes",
            nj_dependent_enrolled_full_time: "yes",
            nj_dependent_five_months_in_college: "yes",
            nj_filer_pays_tuition_for_dependent: "no"
          }
        }
      }
    end

    context "with valid params" do
      it "saves successfully" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        expect(intake.dependents[0].nj_dependent_attends_accredited_program).to eq "yes"
        expect(intake.dependents[0].nj_dependent_enrolled_full_time).to eq "no"
        expect(intake.dependents[0].nj_dependent_five_months_in_college).to eq "no"
        expect(intake.dependents[0].nj_filer_pays_tuition_for_dependent).to eq "yes"

        expect(intake.dependents[1].nj_dependent_attends_accredited_program).to eq "yes"
        expect(intake.dependents[1].nj_dependent_enrolled_full_time).to eq "yes"
        expect(intake.dependents[1].nj_dependent_five_months_in_college).to eq "yes"
        expect(intake.dependents[1].nj_filer_pays_tuition_for_dependent).to eq "no"
      end
    end
  end
end
