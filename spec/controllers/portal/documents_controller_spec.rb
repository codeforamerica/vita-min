require 'rails_helper'

describe Portal::DocumentsController do
  let(:params) { { id: document.id } }
  let(:client) { create :client }
  let(:document) { create :document, client: client }
  let(:transient_url) { "https://gyr-demo.s3.amazonaws.com/data.csv?sig=whatever&expires=whatever" }

  describe "#show" do

    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :show

    context "when logged in" do
      context "when the document does not belong to the client" do
        before do
          sign_in create :client
        end

        it "shows a not found page" do
          get :show, params: params

          expect(response).to be_not_found
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