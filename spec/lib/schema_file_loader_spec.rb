require "rails_helper"

describe SchemaFileLoader do
  it "all required schema files are present" do
    expect(SchemaFileLoader::EFILE_SCHEMAS_FILENAMES).to match_array [
      ["efile1040x_2020v5.1.zip", "irs"],
      ["efile1040x_2021v5.2.zip", "irs"],
      ["efile1040x_2022v5.3.zip", "irs"],
      ["efile1040x_2023v5.0.zip", "irs"],
      ["AZIndividual2024v2.1.zip", "us_states"],
      ["MDIndividual2024v1.0.zip", "us_states"],
      ["NCIndividual2024v1.0.zip", "us_states"],
      ["NJIndividual2024V0.1.zip", "us_states"],
      ["NYSIndividual2023V4.0.zip", "us_states"],
      ["ID_MeF2024V0.1.zip", "us_states"],
    ]
  end

  describe "#s3_credentials" do
    context "AWS_ACCESS_KEY_ID in ENV" do
      it "uses the environment variables" do
        stub_const("ENV", {
          "AWS_ACCESS_KEY_ID" => "mock-aws-access-key-id",
          "AWS_SECRET_ACCESS_KEY" => "mock-aws-secret-access-key"
        })
        credentials = SchemaFileLoader.s3_credentials
        expect(credentials.access_key_id).to eq "mock-aws-access-key-id"
      end
    end

    context "without AWS_ACCESS_KEY_ID in ENV" do
      it "uses the rails credentials" do
        stub_const("ENV", {})
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return "mock-aws-access-key-id"
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return "mock-aws-secret-access-key"
        credentials = SchemaFileLoader.s3_credentials
        expect(credentials.access_key_id).to eq "mock-aws-access-key-id"
      end
    end
  end

  describe "#prepare_directories" do
    it "removes and recreates directories" do
      expect(FileUtils).to receive(:rm_rf).with("testy/irs/unpacked")
      expect(FileUtils).to receive(:mkdir_p).with("testy/irs/unpacked")
      expect(FileUtils).to receive(:rm_rf).with("testy/us_states/unpacked")
      expect(FileUtils).to receive(:mkdir_p).with("testy/us_states/unpacked")
      SchemaFileLoader.prepare_directories("testy")
    end
  end

  describe "#download_schemas_from_s3" do
    it "downloads all schemas from S3" do
      stub_const("ENV", {
        "AWS_ACCESS_KEY_ID" => "mock-aws-access-key-id",
        "AWS_SECRET_ACCESS_KEY" => "mock-aws-secret-access-key"
      })
      SchemaFileLoader::EFILE_SCHEMAS_FILENAMES.each do |(file_name, dir)|
        expect_any_instance_of(Aws::S3::Client).to receive(:get_object).with(
          response_target: "testy/#{dir}/#{file_name}",
          bucket: "vita-min-irs-e-file-schema-prod",
          key: file_name,
          )
      end
      SchemaFileLoader.download_schemas_from_s3("testy")
    end

    context "when file is not found" do
      it "should raise an error" do
        allow(SchemaFileLoader).to receive(:get_missing_downloads).with('some_dir').and_return [["state_secrets.zip", 'dir']]
        allow_any_instance_of(Aws::S3::Client).to receive(:get_object).and_raise Aws::S3::Errors::NoSuchKey.new("Meant to be a context", "Meant to be a message")

        expect { SchemaFileLoader.download_schemas_from_s3('some_dir') }.to raise_error Aws::S3::Errors::NoSuchKey
      end
    end
  end

  describe "#get_missing_downloads" do
    it "gets missing downloads" do
      expect(SchemaFileLoader.get_missing_downloads("testy")).to match_array(
        [
          ["testy/irs/efile1040x_2020v5.1.zip", 'irs'],
          ["testy/irs/efile1040x_2021v5.2.zip", 'irs'],
          ["testy/irs/efile1040x_2022v5.3.zip", 'irs'],
          ["testy/irs/efile1040x_2023v5.0.zip", 'irs'],
          ["testy/us_states/AZIndividual2024v2.1.zip", 'us_states'],
          ["testy/us_states/MDIndividual2024v1.0.zip", 'us_states'],
          ["testy/us_states/NCIndividual2024v1.0.zip", 'us_states'],
          ["testy/us_states/NJIndividual2024V0.1.zip", 'us_states'],
          ["testy/us_states/NYSIndividual2023V4.0.zip", 'us_states'],
          ["testy/us_states/ID_MeF2024V0.1.zip", "us_states"]
        ]
      )
    end
  end
end
