require 'rails_helper'

describe 'DirectFileJsonData' do
  let(:intake) { create :state_file_id_intake, :single_filer_with_json}
  let(:direct_file_json_data) { intake.direct_file_json_data }

  describe "#primary_first_name" do
    it "can read value" do
      expect(direct_file_json_data.primary_first_name).to eq "Lana"
    end
  end
end