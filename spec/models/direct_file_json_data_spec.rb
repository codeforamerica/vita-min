require 'rails_helper'

describe 'DirectFileJsonData' do
  describe "for a single filer" do
    let(:intake) { create :state_file_id_intake, :single_filer_with_json}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    it "can read value" do
      expect(direct_file_json_data.primary_first_name).to eq "Lana"
      expect(direct_file_json_data.primary_dob).to eq "1980-01-01"
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

      expect(direct_file_json_data.primary_dob).to eq "1980-01-01"
      expect(direct_file_json_data.spouse_dob).to eq "1980-01-01"
    end
  end
end