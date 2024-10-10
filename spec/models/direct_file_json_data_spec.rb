require 'rails_helper'

describe DirectFileJsonData do
  describe "for a single filer" do
    let(:intake) { create :state_file_id_intake, :single_filer_with_json}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    it "can read value" do
      expect(direct_file_json_data.primary_first_name).to eq "Lana"
      expect(direct_file_json_data.primary_dob).to eq Date.parse("1980-01-01")
      expect(direct_file_json_data.primary_middle_initial).to eq nil
      expect(direct_file_json_data.primary_last_name).to eq "Turner"
    end
  end

  describe "for a mfj filer" do
    let(:intake) { create :state_file_id_intake, :mfj_filer_with_json}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    it "can read value" do
      expect(direct_file_json_data.primary_first_name).to eq "Paul"
      expect(direct_file_json_data.spouse_first_name).to eq "Sydney"

      expect(direct_file_json_data.primary_middle_initial).to eq "S"
      expect(direct_file_json_data.spouse_middle_initial).to eq nil

      expect(direct_file_json_data.primary_last_name).to eq "Revere"
      expect(direct_file_json_data.spouse_last_name).to eq "Revere"

      expect(direct_file_json_data.primary_dob).to eq Date.parse("1980-01-01")
      expect(direct_file_json_data.spouse_dob).to eq Date.parse("1980-01-01")
    end
  end

  describe "#find_matching_json_dependent" do
    let(:intake) { create :state_file_id_intake, :with_dependents}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    let(:dependents) { intake.dependents }

    before do
      intake.synchronize_df_dependents_to_database
    end

    it "should be able to find matching dependent from xml in json" do
      expect(direct_file_json_data.find_matching_json_dependent(dependents[0])["firstName"]).to eq("Gloria")
      expect(direct_file_json_data.find_matching_json_dependent(dependents[1])["firstName"]).to eq("Patrick")
      expect(direct_file_json_data.find_matching_json_dependent(dependents[2])["firstName"]).to eq("Jack")
    end

    it "should be return nil if xml dependent has no ssn" do
      intake.dependents.last.update(ssn: nil)
      expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.last)).to eq(nil)
    end

    it "should be return nil if xml dependent does not have matching ssn" do
      intake.dependents.last.update(ssn: '100-00-0001')
      expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.last)).to eq(nil)
    end

    context "no tin in json" do
      before do
        allow(direct_file_json_data).to receive(:dependents).and_return(
          [{
             "firstName" => "Gloria",
             "middleInitial" => "T",
             "lastName" => "Hemingway",
             "dateOfBirth" => "1920-01-01",
             "relationship" => "grandParent",
             "eligibleDependent" => true,
             "isClaimedDependent" => true
             # no ssn in json
           }]
        )
      end

      it "should be return nil if xml dependent has no ssn and json dependent also has no tin" do
        intake.dependents.first.update(ssn: nil)
        expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.first)).to eq(nil)
      end
    end
  end
end