require 'rails_helper'

describe 'DirectFileJsonData' do
  let(:direct_file_json_data) {
    DirectFileJsonData.new({
                              familyAndHousehold: [
                                {
                                  firstName: "Jane",
                                  middleInitial: "T",
                                  lastName: "Smith",
                                  dateOfBirth: "2020-01-01",
                                  relationship: "biologicalChild",
                                  eligibleDependent: true,
                                  isClaimedDependent: true
                                },
                                {
                                  firstName: "John",
                                  middleInitial: "G",
                                  lastName: "Smith",
                                  dateOfBirth: "2019-01-01",
                                  relationship: "biologicalChild",
                                  eligibleDependent: true,
                                  isClaimedDependent: true
                                }
                              ],
                              filers: [
                                {
                                  firstName: "Joan",
                                  middleInitial: nil,
                                  lastName: "Smith",
                                  dateOfBirth: "1980-01-01",
                                  isPrimaryFiler: true
                                }
                              ]
                            }.to_json)
  }

  describe "#primary_first_name" do
    it "can read value" do
      expect(direct_file_json_data.primary_first_name).to eq "Joan"
    end
  end
end