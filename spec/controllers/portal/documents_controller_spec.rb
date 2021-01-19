require 'rails_helper'

describe Portal::DocumentsController do
  let(:params) { { id: document.id } }
  let(:client) { create :client }
  let(:document) { create :document, client: client }
  let(:transient_url) { "https://gyr-demo.s3.amazonaws.com/data.csv?sig=whatever&expires=whatever" }

  describe '#show' do
    context "when not logged in" do
      it "redirects to root_url" do
        get :show, params: params
        expect(response).to redirect_to :root
      end
    end

    context "when logged in" do

      context "when the document does not belong to the client" do
        before do
          sign_in create :client
        end

        it "redirects to the client's portal dashboard" do
          get :show, params: params

          expect(response).to redirect_to :portal_root
        end
      end

      context "when the document belongs to the client" do
        before do
          sign_in client
          allow(subject).to receive(:transient_storage_url).and_return(transient_url)
        end

        it "redirects to the document url" do
          get :show, params: params
          expect(response).to redirect_to transient_url
          expect(subject).to have_received(:transient_storage_url).with document.upload.blob
        end
      end
    end
  end
end