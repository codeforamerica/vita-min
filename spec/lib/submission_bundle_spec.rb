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

    context "AZ state" do
      let(:submission) {
        create(:efile_submission, data_source: create(:state_file_az_intake, :with_efile_device_infos, federal_submission_id: fed_return_submission_id), irs_submission_id: state_return_submission_id)
      }

      it "can bundle a minimal AZ return", required_schema: "az" do
        expect(described_class.new(submission).build.errors).to eq([])
        expect(submission.submission_bundle.attached?).to be true
      end

      it "adds the 3 required xml files into the bundle", required_schema: "az" do
        described_class.new(submission).build
        archive = submission.submission_bundle
        expect(archive).not_to be_nil

        path = ActiveStorage::Blob.service.path_for(archive.key)
        filenames = Zip::File.open(path) { |zf| zf.map(&:name) }
        expect(filenames).to eq(["manifest/manifest.xml", "xml/submission.xml", "irs/xml/federalreturn.xml"])
      end

      it "includes a copy of the federal return xml in the generated bundle", required_schema: "az" do
        described_class.new(submission).build
        expected = submission.data_source.raw_direct_file_data

        path = ActiveStorage::Blob.service.path_for(submission.submission_bundle.key)
        Zip::File.open(path) do |zf|
          zf.each do |file|
            next unless file.name == "irs/xml/federalreturn.xml"
            actual = file.get_input_stream.read
            expect(actual).to eq(expected)
          end
        end
      end
    end

    context "XML processing" do
      let(:submission) do
        create(
          :efile_submission,
          data_source: create(
            :state_file_md_intake,
            :with_efile_device_infos,
            federal_submission_id: fed_return_submission_id
          ),
          irs_submission_id: state_return_submission_id
        )
      end

      it "utilizes the delete blank node method", required_schema: "md" do
        expect_any_instance_of(XmlMethods).to receive(:delete_blank_nodes)
        described_class.new(submission).build
      end

      context "when there are errors in the submission bundle" do
        before do
          submission.data_source.update(
            political_subdivision: nil,
            subdivision_code: nil,
          )
        end

        it "does not utilize the delete blank node method", required_schema: "md" do
          expect_any_instance_of(XmlMethods).not_to receive(:delete_blank_nodes)
          described_class.new(submission).build
        end
      end
    end
  end
end
