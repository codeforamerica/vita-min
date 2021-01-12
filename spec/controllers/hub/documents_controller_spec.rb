require 'rails_helper'

RSpec.describe Hub::DocumentsController, type: :controller do
  let(:organization) { create :organization }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
  let(:client) { create :client, vita_partner: organization, intake: create(:intake, vita_partner: organization) }

  describe "#index" do
    let(:params) { { client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
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

  describe "#new" do
    let!(:tax_return_1) { create :tax_return, client: client, year: 2020 }
    let!(:tax_return_2) { create :tax_return, client: client, year: 2019 }
    let(:params) do
      { client_id: client.id }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new

    context "as an authenticated user" do
      render_views

      before { sign_in user }

      it "lists the available tax returns" do
        get :new, params: params

        tax_return_select = Nokogiri::HTML.parse(response.body).at_css("select#document_tax_return_id")
        expect(tax_return_select).to have_text "2020"
        expect(tax_return_select).to have_text "2019"
      end
    end
  end

  describe "#edit" do
    let(:document) { create :document, client: client }
    let(:params) { { id: document.id, client_id: client.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      render_views

      before do
        sign_in user
        create :tax_return, client: client, year: 2020
        create :tax_return, client: client, year: 2019
      end

      it "lists the available tax returns" do
        get :new, params: params

        tax_return_select = Nokogiri::HTML.parse(response.body).at_css("select#document_tax_return_id")
        expect(tax_return_select).to have_text "2020"
        expect(tax_return_select).to have_text "2019"
      end
    end
  end

  describe "#update" do
    let(:new_display_name) { "New Display Name" }
    let(:new_tax_return) { create :tax_return, client: client }
    let(:new_doc_type) { DocumentTypes::Employment }
    let(:document) { create :document, client: client }
    let(:params) do
      {
        client_id: client.id,
        id: document.id,
        document: {
          display_name: new_display_name,
          tax_return_id: new_tax_return.id,
          document_type: new_doc_type.key
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "with an authenticated user" do
      before { sign_in(user) }

      context "with valid params" do
        it "updates the document attributes" do
          post :update, params: params

          expect(response).to redirect_to(hub_client_documents_path(client_id: client.id))
          document.reload
          expect(document.display_name).to eq new_display_name
          expect(document.document_type).to eq new_doc_type.key
          expect(document.tax_return_id).to eq new_tax_return.id
        end
      end

      context "invalid params" do
        render_views

        let(:params) do
          {
            client_id: client.id,
            id: document.id,
            document: {
              document_type: 'Nonexistent'
            }
          }
        end

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
    let(:document) { create :document, client: client }
    let(:params) { { client_id: client.id, id: document.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with a signed in user" do
      let(:document_transient_url) { "https://gyr-demo.s3.amazonaws.com/document.pdf?sig=whatever&expires=whatever" }
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
    let!(:intake) { client.intake }
    let!(:tax_return) { create :tax_return, client: client, year: 2017 }

    let(:params) do
      { client_id: client.id,
        document: {
          upload: [
              fixture_file_upload("attachments/test-pattern.png", "image/png"),
              fixture_file_upload("attachments/document_bundle.pdf", "application/pdf")
          ],
          tax_return_id: tax_return.id,
          display_name: "This is a document for the client",
          document_type: DocumentTypes::Form1098E.key
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "with an authenticated user" do
      before { sign_in(user) }

      it "appends the documents to the client's documents list" do
        expect {
          post :create, params: params
        }.to change(Document, :count).by 2

        latest_docs = Document.last(2)
        expect(latest_docs.map(&:document_type).uniq).to eq ["1098-E"]
        expect(latest_docs.first.upload.filename).to eq "test-pattern.png"
        expect(latest_docs.second.upload.filename).to eq "document_bundle.pdf"
        expect(latest_docs.first.display_name).to eq "This is a document for the client"
        expect(latest_docs.second.display_name).to eq "This is a document for the client"
        expect(latest_docs.map(&:client).uniq).to eq [client]
        expect(latest_docs.map(&:tax_return_id).uniq).to eq [tax_return.id]
        expect(latest_docs.map(&:uploaded_by).uniq).to eq [user]
        expect(response).to redirect_to(hub_client_documents_path(client_id: client.id))
      end

      context "with no display name, or tax return" do
        let(:params) do
          { client_id: client.id,
            document: {
              upload: [
                fixture_file_upload("attachments/test-pattern.png", "image/png"),
                fixture_file_upload("attachments/document_bundle.pdf", "application/pdf")
              ],
              display_name: "",
              document_type: DocumentTypes::Other.key
            }
          }
        end

        it "sets default file name, does not set tax return" do
          post :create, params: params

          latest_docs = Document.last(2)
          expect(latest_docs.first.display_name).to eq "test-pattern.png"
          expect(latest_docs.second.display_name).to eq "document_bundle.pdf"
          expect(latest_docs.map(&:tax_return_id).uniq).to eq [nil]
        end
      end

      context "without an explicit document_type specified" do
        before do
          params[:document].delete(:document_type)
        end

        it "successfully creates the documents and set the document type to the default doc type, Other" do
          expect {
            post :create, params: params
          }.to change(Document, :count).by 2
          latest_docs = Document.last(2)

          expect(latest_docs.map(&:document_type).uniq).to eq ["Other"]
        end
      end
    end
  end
end
