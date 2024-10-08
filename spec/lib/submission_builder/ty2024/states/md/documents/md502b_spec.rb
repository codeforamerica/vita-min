require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502b, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "dependent counts" do
      before do
        allow_any_instance_of(Efile::Md::Md502bCalculator).to receive(:calculate_line_1).and_return 2
        allow_any_instance_of(Efile::Md::Md502bCalculator).to receive(:calculate_line_2).and_return 1
        allow_any_instance_of(Efile::Md::Md502bCalculator).to receive(:calculate_line_3).and_return 3
      end

      it "fills out the correct counts" do
        expect(xml.at("Form502B Dependents CountRegular").text).to eq "2"
        expect(xml.at("Form502B Dependents CountOver65").text).to eq "1"
        expect(xml.at("Form502B Dependents Count").text).to eq "3"
      end
    end

    context "filling out dependent details" do
      let(:young_dob) { StateFileDependent.senior_cutoff_date + 60.years }
      let(:old_dob) { StateFileDependent.senior_cutoff_date }
      let!(:dependent) do
        create(
          :state_file_dependent,
          intake: intake,
          first_name: "Janiss",
          middle_initial: "J",
          last_name: "Jawplyn",
          ssn: "123456789",
          relationship: "DAUGHTER",
          dob: young_dob,
        )
      end
      let!(:senior_dependent) do
        create(
          :state_file_dependent,
          intake: intake,
          first_name: "Jeanie",
          middle_initial: "F",
          last_name: "Jimplin",
          ssn: "234567890",
          relationship: "GRANDPARENT",
          dob: old_dob,
        )
      end

      it "fills out the correct details for each dependent" do
        dependent_1 = xml.at("Form502B Dependents").css("Dependent")[0]
        expect(dependent_1.at("Name FirstName").text).to eq "Janiss"
        expect(dependent_1.at("Name MiddleInitial").text).to eq "J"
        expect(dependent_1.at("Name LastName").text).to eq "Jawplyn"
        expect(dependent_1.at("SSN").text).to eq "123456789"
        expect(dependent_1.at("RelationToTaxpayer").text).to eq "Child"
        expect(dependent_1.at("ClaimedAsDependent").text).to eq "X"
        expect(dependent_1.at("Over65")).to be_nil
        expect(dependent_1.at("DependentDOB").text).to eq young_dob.strftime("%Y-%m-%d")

        dependent_2 = xml.at("Form502B Dependents").css("Dependent")[1]
        expect(dependent_2.at("Name FirstName").text).to eq "Jeanie"
        expect(dependent_2.at("Name MiddleInitial").text).to eq "F"
        expect(dependent_2.at("Name LastName").text).to eq "Jimplin"
        expect(dependent_2.at("SSN").text).to eq "234567890"
        expect(dependent_2.at("RelationToTaxpayer").text).to eq "Grandparent"
        expect(dependent_2.at("ClaimedAsDependent").text).to eq "X"
        expect(dependent_2.at("Over65").text).to eq "X"
        expect(dependent_2.at("DependentDOB").text).to eq old_dob.strftime("%Y-%m-%d")
      end
    end
  end
end