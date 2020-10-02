require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  describe "#index" do
    let(:client) { create :client }
    let(:params) { { client_id: client.id }}

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "with a signed in beta tester" do
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
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

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
  end

  describe "#show" do
    let(:document) { create :document, :with_upload }
    let(:params) { { id: document.id }}

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
    let(:params) { { id: document.id, client_id: client.id, document_form: { display_name: new_display_name} } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update
    it_behaves_like :a_post_action_for_beta_testers_only, action: :update

    context "with a signed in beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

      it "updates the display name attribute on the document" do
        post :update, params: params

        expect(response).to redirect_to(client_documents_path(client_id: client.id))
        document.reload
        expect(document.display_name).to eq new_display_name
      end
    end
  end

  context "#delete" do
    let!(:document) { create :document }

    it "requires a current intake" do
      expect do
        delete :destroy, params: { id: document.id }
      end.not_to change(Document, :count)

      expect(response).to redirect_to(welcome_questions_path)
    end

    context "with an authenticated user" do
      let(:params) do
        { id: document.id }
      end

      before do
        allow(controller).to receive(:current_intake).and_return(document.intake)
      end

      it "allows them to delete their own document and redirects back" do
        expect do
          delete :destroy, params: params
        end.to change(Document, :count).by(-1)

        expect(response).to redirect_to w2s_documents_path
      end

      context "with a document id that does not exist" do
        let(:params) do
          { id: 123874619823764 }
        end

        it "simply redirects to the documents overview page" do
          expect do
            delete :destroy, params: params
          end.not_to change(Document, :count)

          expect(response).to redirect_to(overview_documents_path)
        end
      end
    end
  end
end
