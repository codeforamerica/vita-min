require "rails_helper"

# TODO: .new is only needed if we are testing instance access instead of table access.
#   Consider removing .new in specs below unless necessary

describe SchemaFileLoader do

  it "all required schema files are present" do
    expect(SchemaFileLoader::EFILE_SCHEMAS_FILENAMES).to eq [
      ["efile1040x_2020v5.1.zip", "irs"],
      ["efile1040x_2021v5.2.zip", "irs"],
      ["efile1040x_2022v5.3.zip", "irs"],
      ["efile1040x_2023v5.0.zip", "irs"],
      ["NYSIndividual2023V4.0.zip", "us_states"],
      ["AZIndividual2023v1.0.zip", "us_states"],
    ]
  end

  context "s3_credentials" do

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
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return "mock-aws-access-key-id"
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return "mock-aws-secret-access-key"
        credentials = SchemaFileLoader.s3_credentials
        expect(credentials.access_key_id).to eq "mock-aws-access-key-id"
      end
    end
  end

  context "prepare_directories" do
    it "removes and recreates directories" do
      expect(FileUtils).to receive(:rm_rf).with("testy/irs/unpacked")
      expect(FileUtils).to receive(:mkdir_p).with("testy/irs/unpacked")
      expect(FileUtils).to receive(:rm_rf).with("testy/us_states/unpacked")
      expect(FileUtils).to receive(:mkdir_p).with("testy/us_states/unpacked")
      SchemaFileLoader.prepare_directories("testy")
    end
  end

  context "download_schemas_from_s3" do
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
  end

  context "get_missing_downloads" do
    it "gets missing downloads" do
      expect(SchemaFileLoader.get_missing_downloads("testy")).
        to eq [
          "testy/irs/efile1040x_2020v5.1.zip",
          "testy/irs/efile1040x_2021v5.2.zip",
          "testy/irs/efile1040x_2022v5.3.zip",
          "testy/irs/efile1040x_2023v5.0.zip",
          "testy/us_states/NYSIndividual2023V4.0.zip",
          "testy/us_states/AZIndividual2023v1.0.zip"
        ]
    end
  end
end
