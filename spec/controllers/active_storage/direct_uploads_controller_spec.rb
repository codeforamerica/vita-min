require "rails_helper"

RSpec.describe ActiveStorage::DirectUploadsController, type: :controller do
  describe "#create" do
    let(:valid_params) do
      {
        blob: {
          filename: "test.txt",
          byte_size: 123,
          checksum: Base64.strict_encode64(Digest::MD5.digest("test content")),
          content_type: "text/plain",
          metadata: {}
        }
      }
    end

    it "creates a blob with normal metadata" do
      params_with_metadata = valid_params.deep_dup
      params_with_metadata[:blob][:metadata] = { "normal_key" => "normal_value" }

      expect {
        post :create, params: params_with_metadata, as: :json
      }.to change(ActiveStorage::Blob, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "strips the 'custom' key from metadata instead of raising a 500" do
      params_with_custom = valid_params.deep_dup
      params_with_custom[:blob][:metadata] = { "custom" => "trigger_error", "safe_key" => "safe_value" }

      expect {
        post :create, params: params_with_custom, as: :json
      }.to change(ActiveStorage::Blob, :count).by(1)

      expect(response).to have_http_status(:ok)

      blob = ActiveStorage::Blob.last
      expect(blob.metadata).not_to have_key("custom")
      expect(blob.metadata["safe_key"]).to eq("safe_value")
    end

    it "handles metadata with only the 'custom' key" do
      params_with_only_custom = valid_params.deep_dup
      params_with_only_custom[:blob][:metadata] = { "custom" => "trigger_error" }

      expect {
        post :create, params: params_with_only_custom, as: :json
      }.to change(ActiveStorage::Blob, :count).by(1)

      expect(response).to have_http_status(:ok)
    end
  end
end
