require 'rails_helper'

describe ActiveStorage::Representations::RedirectController do
  let(:document) { create(:document, upload_path: (Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))) }

  it "returns a signed url to see the resized image" do
    representation = document.upload.representation(resize: "140x140")
    get :show, params: { signed_blob_id: document.upload.blob.signed_id, variation_key: representation.variation.key, filename: 'picture_id.jpg' }

    expect(response).to redirect_to(/.*\/rails\/active_storage\/.*picture_id.jpg/)
  end

  context 'when the document cannot be resized' do
    it "returns a default image path" do
      variation_key = document.upload.representation(resize: "140x140").variation.key
      signed_blob_id = document.upload.blob.signed_id

      allow_any_instance_of(ActiveStorage::Blob).to receive(:variant).and_raise(StandardError)

      get :show, params: { signed_blob_id: signed_blob_id, variation_key: variation_key, filename: 'picture_id.jpg' }

      expect(response).to redirect_to(/document.*svg/)
    end
  end

  context 'when the document takes too long to resize' do
    before do
      allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
    end

    it "returns a default image path" do
      representation = document.upload.representation(resize: "140x140")
      get :show, params: { signed_blob_id: document.upload.blob.signed_id, variation_key: representation.variation.key, filename: 'picture_id.jpg' }

      expect(response).to redirect_to(/document.*svg/)
    end
  end
end
