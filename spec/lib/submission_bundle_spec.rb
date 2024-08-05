require "rails_helper"

describe SubmissionBundle do

  around do |example|
    ENV["TEST_SCHEMA_VALIDITY_ONLY"] = 'true'
    example.run
    ENV.delete("TEST_SCHEMA_VALIDITY_ONLY")
  end

  describe "state filing" do
    let(:fed_return_submission_id) { "12345202201011234570" }
    let(:state_return_submission_id) { "44445202201011234577" }
    context "NY state" do
      let(:submission) do
        create(
          :efile_submission,
          data_source: create(
            :state_file_ny_intake,
            :with_efile_device_infos,
            federal_submission_id: fed_return_submission_id,
            school_district_id: 441,
            school_district: "Bellmore-Merrick CHS",
            school_district_number: 46
          ),
          irs_submission_id: state_return_submission_id
        )
      end
      it "can bundle a minimal NY return" do
        expect(described_class.new(submission).build.errors).to eq([])
      end
    end

    context "AZ state" do
      let(:submission) {
        create(:efile_submission, data_source: create(:state_file_az_intake, :with_efile_device_infos, federal_submission_id: fed_return_submission_id), irs_submission_id: state_return_submission_id)
      }

      it "can bundle a minimal AZ return" do
        expect(described_class.new(submission).build.errors).to eq([])
      end
    end
  end
end
