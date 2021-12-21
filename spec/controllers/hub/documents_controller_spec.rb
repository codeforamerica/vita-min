require 'rails_helper'

RSpec.describe Hub::DocumentsController, type: :controller do
  let(:organization) { create :organization }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
  let(:client) { create :client, vita_partner: organization, intake: create(:intake, vita_partner: organization) }
  let(:user_agent) { "GeckoFox" }
  let(:ip_address) { "127.0.0.1" }

  before do
    request.remote_ip = ip_address
    request.user_agent = user_agent
  end

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
        let!(:fourth_document) do
          doc = build :document,
                      display_name: "zero-bytes.jpg",
                      document_type: "Email Attachment",
                      created_at: 1.hour.ago,
                      client: client,
                      upload_path: Rails.root.join("spec", "fixtures", "files", "zero-bytes.jpg")
          doc.save(validate: false)
          doc
        end
        let!(:archived_document) { create :archived_document, client: client }

        it "displays all the documents for the client" do
          get :index, params: params

          html = Nokogiri::HTML.parse(response.body)
          first_doc_element = html.at_css("#document-#{first_document.id}")
          expect(first_doc_element).to have_text("ID")
          expect(first_doc_element).to have_text("some_file.jpg")
          document_link = first_doc_element.at_css("a:contains(\"some_file.jpg\")")
          expect(document_link["href"]).to eq hub_client_document_path(client_id: client.id, id: first_document.id)
          second_doc_element = html.at_css("#document-#{second_document.id}")
          expect(second_doc_element).to have_text("Employment")
          expect(second_doc_element).to have_text("another_file.pdf")
          third_doc_element = html.at_css("#document-#{third_document.id}")
          expect(third_doc_element).to have_text("Email attachment")
          expect(third_doc_element).to have_text("email-attachment.pdf")
          fourth_doc_element = html.at_css("#document-#{fourth_document.id}")
          expect(fourth_doc_element).to have_text("Email attachment")
          expect(fourth_doc_element).to have_text("zero-bytes.jpg (empty file)")
        end

        it "excludes archived documents but has a link for them in last row of the table" do
          get :index, params: params

          expect(assigns(:documents)).not_to include archived_document
          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("tbody tr:last-child a")).to have_text "Archived documents"
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

  describe "#archived" do
    let(:params) { { client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :archived

    context "as an authenticated user" do
      let!(:not_archived_document) { create :document, client: client }
      let!(:archived_document) { create :archived_document, client: client }
      before { sign_in(user) }

      it "shows only archived documents, no other documents" do
        get :archived, params: params

        expect(assigns(:documents)).to include archived_document
        expect(assigns(:documents)).not_to include not_archived_document
      end

      context "when rendering" do
        render_views

        it "includes a link to return to documents index" do
          get :archived, params: params

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css(".actions-section a")).to have_text "Documents"
          expect(html.at_css(".actions-section a")["href"]).to eq hub_client_documents_path(client_id: client)
        end
      end
    end
  end

  describe "#new" do
    let!(:tax_return_1) { create :tax_return, client: client, year: TaxReturn.current_tax_year }
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
        expect(tax_return_select).to have_text TaxReturn.current_tax_year
        expect(tax_return_select).to have_text "2019"
      end
    end
  end

  describe "#edit" do
    let(:document) { create :document, client: client }
    let(:params) { { id: document.id, client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      render_views

      before do
        sign_in user
        create :tax_return, client: client, year: 2021
        create :tax_return, client: client, year: 2019
      end

      it "lists the available tax returns" do
        get :edit, params: params
        tax_return_select = Nokogiri::HTML.parse(response.body).at_css("select#document_tax_return_id")
        expect(tax_return_select).to have_text "2021"
        expect(tax_return_select).to have_text "2019"
      end
    end
  end

  describe "#update" do
    let(:new_display_name) { "New Display Name" }
    let(:new_tax_return) { create :tax_return, client: client }
    let(:new_doc_type) { DocumentTypes::Employment }
    let(:document) { create :document, client: client, uploaded_by: client }
    let(:params) do
      {
        client_id: client.id,
        id: document.id,
        document: {
          display_name: new_display_name,
          tax_return_id: new_tax_return.id,
          document_type: new_doc_type.key,
          archived: "true"
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
          expect(document.uploaded_by).to eq client
          expect(document.archived).to eq true
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

      it "creates an access log with the logged in user" do
        expect {
          get :show, params: params
        }.to change(AccessLog, :count).by(1)

        access_log = AccessLog.last
        expect(access_log.user).to eq user
        expect(access_log.record).to eq document
        expect(access_log.event_type).to eq "viewed_document"
        expect(access_log.ip_address).to eq ip_address
        expect(access_log.user_agent).to eq user_agent
      end
    end
  end

  describe "#create" do
    let!(:intake) { client.intake }
    let!(:tax_return) { create :tax_return, client: client, year: 2017 }
    let(:document_type) { DocumentTypes::Form1098E.key }
    let(:upload) { fixture_file_upload("test-pattern.png", "image/png") }

    let(:params) do
      { client_id: client.id,
        document: {
          upload: upload,
          tax_return_id: tax_return.id,
          display_name: "This is a document for the client",
          document_type: document_type
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "with an authenticated user" do
      before { sign_in(user) }

      it "appends the document to the client's documents list and redirects to client index" do
        expect {
          post :create, params: params
        }.to change(Document, :count).by 1

        latest_doc = Document.last
        expect(latest_doc.document_type).to eq "1098-E"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"
        expect(latest_doc.display_name).to eq "This is a document for the client"
        expect(latest_doc.client).to eq client
        expect(latest_doc.tax_return_id).to eq tax_return.id
        expect(latest_doc.uploaded_by).to eq user
        expect(response).to redirect_to(hub_client_documents_path(client_id: client.id))
      end

      context "when the document type requires confirmation" do
        let(:document_type) { DocumentTypes::FinalTaxDocument.key }
        let(:upload) { fixture_file_upload("document_bundle.pdf", "application/pdf") }
        it "redirects to the confirmation page after creation" do
          expect {
            post :create, params: params
          }.to change(client.documents, :count).by 1

          doc = Document.last
          expect(response).to redirect_to confirm_hub_client_document_path(id: doc.id, client_id: doc.client.id)
        end
      end

      context "with no display name, or tax return" do
        let(:params) do
          { client_id: client.id,
            document: {
              upload: fixture_file_upload("test-pattern.png", "image/png"),
              display_name: "",
              document_type: DocumentTypes::Other.key
            }
          }
        end

        it "sets default file name, does not set tax return" do
          post :create, params: params

          latest_doc = Document.last
          expect(latest_doc.display_name).to eq "test-pattern.png"
          expect(latest_doc.tax_return_id).to eq nil
        end
      end

      context "with no file chosen" do
        before do
          params[:document].delete(:upload)
        end

        it "shows a validation error and creates no documents" do
          expect {
            post :create, params: params
          }.not_to change(Document, :count)
          expect(assigns(:document).errors).to include(:upload)
          expect(response).to be_ok
        end
      end

      context "required file types" do
        context "Form 8879 (Unsigned)" do
          render_views

          let(:params) do
            { client_id: client.id,
              document: {
                upload: fixture_file_upload("test-pattern.png", "image/png"),
                tax_return_id: tax_return.id,
                display_name: "This is a document for the client",
                document_type: DocumentTypes::UnsignedForm8879.key
              }
            }
          end

          it "validates that the document is a pdf" do
            post :create, params: params
            expect(assigns(:document).valid?).to eq false

            expect(response).to render_template :new
            expect(response.body).to include "Form 8879 (Unsigned) must be a PDF file"
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:admin) { create :admin_user }
    let!(:document) { create :document, client: client }
    let(:client) { create :client, intake: create(:intake) }
    before do
      sign_in admin
    end

    context "when client id and documents client dont match" do
      let(:params) do
        {
            id: create(:document),
            client_id: client.id
        }
      end

      it "raises an error and doesnt alter document" do
        expect {
          delete :destroy, params: params
        }.to raise_error ActiveRecord::RecordNotFound

        expect(document.reload.archived).to eq false
      end
    end

    context "with reupload param (after the user clicks no on confirmation page)" do
      let(:params) do
        {
            id: document,
            client_id: client.id,
            reupload: true
        }
      end

      it "renders new page with document params and deletes the original document so that the user can reupload" do
        expect {
          delete :destroy, params: params
        }.to change(client.documents, :count).by(-1)

        expect(response).to render_template :new
      end
    end

    context "without reupload param" do
      let(:params) do
        {
            id: document,
            client_id: client.id
        }
      end

      it "archives the document" do
        expect {
          delete :destroy, params: params
        }.not_to change(client.documents, :count)

        expect(document.reload.archived).to eq true
      end
    end
  end
end
