require 'rails_helper'

describe DirectFileJsonData do

  describe "1099-INT" do
    context "with 1099 INT present in the json" do
      let(:intake) { create :state_file_md_intake, :df_data_1099_int }
      it "can read 1099 INT values" do
        expect(intake.direct_file_json_data.interest_reports.count).to eq(1)
        interest_report = intake.direct_file_json_data.interest_reports[0]
        expect(interest_report.amount_1099).to eq(1)
        expect(interest_report.has_1099).to be(true)
        expect(interest_report.interest_on_government_bonds).to eq(2)
        expect(interest_report.amount_no_1099).to eq(3)
        expect(interest_report.recipient_tin).to eq("100-23-4567")
        expect(interest_report.tax_exempt_interest).to eq(4)
        expect(interest_report.payer).to eq("The payer name")
        expect(interest_report.payer_tin).to eq("101-23-4567")
        expect(interest_report.tax_withheld).to eq(5)
        expect(interest_report.tax_exempt_and_tax_credit_bond_cusip_number).to eq("123456789")
      end
    end

    context "with no 1099 INTs present in the json" do
      let(:intake) { create :state_file_md_intake }
      it "finds no 1099 INT values" do
        expect(intake.direct_file_json_data.interest_reports).to be_empty
      end
    end
  end

  describe "for a single filer" do
    let(:intake) { create :state_file_id_intake, :single_filer_with_json}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    it "can read value" do
      expect(direct_file_json_data.primary_filer.first_name).to eq "Lana"
      expect(direct_file_json_data.primary_filer.dob).to eq Date.parse("1980-01-01")
      expect(direct_file_json_data.primary_filer.middle_initial).to eq nil
      expect(direct_file_json_data.primary_filer.last_name).to eq "Turner"
    end
  end

  describe "for a mfj filer" do
    let(:intake) { create :state_file_id_intake, :mfj_filer_with_json}
    let(:direct_file_json_data) { intake.direct_file_json_data }
    it "can read value" do
      expect(direct_file_json_data.primary_filer.first_name).to eq "Paul"
      expect(direct_file_json_data.spouse_filer.first_name).to eq "Sydney"

      expect(direct_file_json_data.primary_filer.middle_initial).to eq "S"
      expect(direct_file_json_data.spouse_filer.middle_initial).to eq nil

      expect(direct_file_json_data.primary_filer.last_name).to eq "Revere"
      expect(direct_file_json_data.spouse_filer.last_name).to eq "Revere"

      expect(direct_file_json_data.primary_filer.dob).to eq Date.parse("1980-01-01")
      expect(direct_file_json_data.spouse_filer.dob).to eq Date.parse("1980-01-01")
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
      expect(direct_file_json_data.find_matching_json_dependent(dependents[0]).first_name).to eq("Gloria")
      expect(direct_file_json_data.find_matching_json_dependent(dependents[1]).first_name).to eq("Patrick")
      expect(direct_file_json_data.find_matching_json_dependent(dependents[2]).first_name).to eq("Jack")
    end

    it "should return nil if xml dependent has no ssn" do
      intake.dependents.last.update(ssn: nil)
      expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.last)).to eq(nil)
    end

    it "should return nil if xml dependent does not have matching ssn" do
      intake.dependents.last.update(ssn: '100-00-0001')
      expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.last)).to eq(nil)
    end

    context "no tin in json" do
      before do

        allow(direct_file_json_data).to receive(:dependents).and_return(
          [DirectFileJsonData::DfJsonDependent.new({
             "firstName" => "Gloria",
             "middleInitial" => "T",
             "lastName" => "Hemingway",
             "dateOfBirth" => "1920-01-01",
             "relationship" => "grandParent",
             "eligibleDependent" => true,
             "isClaimedDependent" => true
             # no ssn in json
           })]
        )
      end

      it "should return nil if xml dependent has no ssn and json dependent also has no tin" do
        intake.dependents.first.update(ssn: nil)
        expect(direct_file_json_data.find_matching_json_dependent(intake.dependents.first)).to eq(nil)
      end
    end
  end
end