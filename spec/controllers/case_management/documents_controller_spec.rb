require 'rails_helper'

RSpec.describe CaseManagement::DocumentsController, type: :controller do
  describe "#index" do
    let(:client) { create :client }
    let(:params) { { client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "with a signed in beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

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
                 document_type: "W-2",
                 created_at: 3.hours.ago,
                 client: client
        }

        it "displays all the documents for the client" do
          get :index, params: params

          html = Nokogiri::HTML.parse(response.body)
          first_doc_element = html.at_css("#document-#{first_document.id}")
          expect(first_doc_element).to have_text("ID")
          expect(first_doc_element).to have_text("some_file.jpg")
          expect(first_doc_element).to have_text("2 days ago")
          second_doc_element = html.at_css("#document-#{second_document.id}")
          expect(second_doc_element).to have_text("W-2")
          expect(second_doc_element).to have_text("another_file.pdf")
          expect(second_doc_element).to have_text("3 hours ago")
        end
      end

      context "sorting and ordering" do
        context "with a sort param" do
          let(:params) { { client_id: client.id, sort: "created_at", order: "desc" } }
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
          let(:params) { { client_id: client.id, sort: "bad_param", order: "nonsensical_order" } }

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
    let(:client) { create :client }
    let(:document) { create :document, :with_upload, client: client }
    let(:params) { { id: document.id, client_id: client.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit
    it_behaves_like :a_get_action_for_beta_testers_only, action: :edit

    context "with a signed in beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

      it "renders edit for the document" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:document)).to eq(document)
      end
    end
  end

  describe "#update" do
    let(:new_display_name) { "New Display Name"}
    let(:client) { create :client }
    let(:document) { create :document, :with_upload, client: client }
    let(:params) { { client_id: client.id, id: document.id, document: { display_name: new_display_name} } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update
    it_behaves_like :a_post_action_for_beta_testers_only, action: :update

    context "with a signed in beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }
      context "with valid params" do
        it "updates the display name attribute on the document" do
          post :update, params: params

          expect(response).to redirect_to(case_management_client_documents_path(client_id: client.id))
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
    let(:client) { create :client }
    let(:document) { create :document, :with_upload, client: client }
    let(:params) { { client_id: client.id, id: document.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
    it_behaves_like :a_get_action_for_beta_testers_only, action: :show

    context "with a signed in beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

      it "shows the document" do
        get :show, params: params

        expect(response).to be_ok
        expect(response.headers["Content-Type"]).to eq("image/jpeg")
      end
    end
  end

end

