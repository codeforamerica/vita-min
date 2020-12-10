require 'rails_helper'

RSpec.describe Hub::DocumentsController, type: :controller do
  describe "#index" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, vita_partner: vita_partner) }
    let(:params) { { client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in(user) }

      context "with some existing documents" do
        render_views

        let!(:first_document) {
          create :document,
                 display_name: "some_file.jpg",
                 document_type: "ID",
                 created_at: 2.days.ago,
                 client: client
        }
        let!(:second_document) {
          create :document,
                 display_name: "another_file.pdf",
                 document_type: "Employment",
                 created_at: 3.hours.ago,
                 client: client
        }
        let!(:third_document) {
          create :document,
                 display_name: "email-attachment.pdf",
                 document_type: "Email Attachment",
                 created_at: 1.hour.ago,
                 client: client
        }

        it "displays all the documents for the client" do
          get :index, params: params

          html = Nokogiri::HTML.parse(response.body)
          first_doc_element = html.at_css("#document-#{first_document.id}")
          expect(first_doc_element).to have_text("ID")
          expect(first_doc_element).to have_text("some_file.jpg")
          expect(first_doc_element).to have_text("2 days ago")
          document_link = first_doc_element.at_css("a:contains(\"some_file.jpg\")")
          expect(document_link["href"]).to eq hub_client_document_path(client_id: client.id, id: first_document.id)
          second_doc_element = html.at_css("#document-#{second_document.id}")
          expect(second_doc_element).to have_text("Employment")
          expect(second_doc_element).to have_text("another_file.pdf")
          expect(second_doc_element).to have_text("3 hours ago")
          third_doc_element = html.at_css("#document-#{third_document.id}")
          expect(third_doc_element).to have_text("Email attachment")
          expect(third_doc_element).to have_text("email-attachment.pdf")
          expect(third_doc_element).to have_text("1 hour ago")
        end
      end

      context "sorting and ordering" do
        context "with a sort param" do
          let(:params) { { client_id: client.id, column: "created_at", order: "desc" } }
          let!(:earlier_document) { create :document, display_name: "Alligator doc", created_at: 1.hour.ago, client: client }
          let!(:later_document) { create :document, display_name: "Zebra doc", created_at: 1.minute.ago, client: client }

          it "orders documents by that column" do
            get :index, params: params

            expect(assigns[:sort_column]).to eq("created_at")
            expect(assigns[:sort_order]).to eq("desc")
            expect(assigns(:documents)).to eq [later_document, earlier_document]
          end
        end

        context "with no params" do
          let(:params) { { client_id: client.id } }
          let!(:identity_document) { create :document, client: client, document_type: DocumentTypes::Identity.key, display_name: "alligator doc" }
          let!(:employment_document) { create :document, client: client, document_type: DocumentTypes::Employment.key, display_name: "zebra doc" }

          it "defaults to sorting by document_type" do
            get :index, params: params
            expect(assigns[:sort_column]).to eq("document_type")
            expect(assigns[:sort_order]).to eq("asc")
            expect(assigns(:documents)).to eq [employment_document, identity_document]
          end
        end

        context "with bad sort param" do
          let!(:identity_document) { create :document, client: client, document_type: DocumentTypes::Identity.key, display_name: "alligator doc" }
          let!(:employment_document) { create :document, client: client, document_type: DocumentTypes::Employment.key, display_name: "zebra doc" }
          let(:params) { { client_id: client.id, column: "bad_param", order: "nonsensical_order" } }

          it "defaults to sorting by document_type" do
            get :index, params: params

            expect(assigns[:sort_column]).to eq("document_type")
            expect(assigns[:sort_order]).to eq("asc")
            expect(assigns(:documents)).to eq [employment_document, identity_document]
          end
        end
      end
    end
  end

  describe "#edit" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, vita_partner: vita_partner) }
    let(:document) { create :document, client: client }
    let(:params) { { id: document.id, client_id: client.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "with an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in(user) }

      it "renders edit for the document" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:document)).to eq(document)
      end
    end
  end

  describe "#update" do
    let(:new_display_name) { "New Display Name"}
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, vita_partner: vita_partner) }
    let(:document) { create :document, client: client }
    let(:params) { { client_id: client.id, id: document.id, document: { display_name: new_display_name} } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "with an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in(user) }
      context "with valid params" do
        it "updates the display name attribute on the document" do
          post :update, params: params

          expect(response).to redirect_to(hub_client_documents_path(client_id: client.id))
          document.reload
          expect(document.display_name).to eq new_display_name
        end
      end

      context "invalid params" do
        let(:params) { { client_id: client.id, id: document.id, document: { display_name: '' } } }

        it "renders edit and does not update the document with invalid data" do
          post :update, params: params

          expect(response).to render_template :edit

          document.reload
          expect(document.display_name).not_to eq ''
        end
      end
    end
  end

  describe "#show" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, vita_partner: vita_partner) }
    let(:document) { create :document, client: client }
    let(:params) { { client_id: client.id, id: document.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a signed in user" do
      let(:document_transient_url) { "https://gyr-demo.s3.amazonaws.com/document.pdf?sig=whatever&expires=whatever" }
      let(:user) { create :user, vita_partner: vita_partner }
      before do
        sign_in(user)
        allow(subject).to receive(:transient_storage_url).and_return(document_transient_url)
      end

      it "shows the document" do
        get :show, params: params

        expect(response).to redirect_to(document_transient_url)
        expect(subject).to have_received(:transient_storage_url).with(document.upload.blob)
      end
    end
  end

  describe "#create" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let!(:intake) { create :intake, client: client }
    let(:params) do
      { client_id: client.id,
        document: {
          upload: [
              fixture_file_upload("attachments/test-pattern.png", "image/png"),
              fixture_file_upload("attachments/document_bundle.pdf", "application/pdf")
          ]
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "with an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in(user) }

      it "appends the documents to the client's documents list" do
        expect {
          post :create, params: params
        }.to change(Document, :count).by 2

        latest_docs = Document.last(2)
        expect(latest_docs.map(&:document_type).uniq).to eq ["Other"]
        expect(latest_docs.first.upload.filename).to eq "test-pattern.png"
        expect(latest_docs.second.upload.filename).to eq "document_bundle.pdf"
        expect(latest_docs.map(&:intake).uniq).to eq [intake]
        expect(latest_docs.map(&:client).uniq).to eq [client]
        expect(response).to redirect_to(hub_client_documents_path(client_id: client.id))
      end
    end
  end
end
