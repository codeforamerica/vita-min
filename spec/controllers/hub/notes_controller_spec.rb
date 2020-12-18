require "rails_helper"

RSpec.describe Hub::NotesController, type: :controller do
  let(:organization) { create :organization }
  let(:client) { create :client, vita_partner: organization }
  let!(:intake) { create :intake, client: client }
  let(:user) { create :user }
  before { create :organization_lead_role, user: user, organization: organization }

  describe "#create" do
    let(:params) {
      {
        client_id: client.id,
        note: {
          body: "Note body"
        }
      }
    }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new note" do
        post :create, params: params

        note = Note.last
        expect(note.body).to eq "Note body"
        expect(note.client).to eq client
        expect(note.user).to eq user
        expect(response).to redirect_to hub_client_notes_path(client_id: client.id)
      end

      context "with invalid params" do
        let(:params) do
          {
              client_id: client.id,
              note: {
                  body: "  "
              }
          }
        end

        it "returns 200 OK and does not save" do
          expect do
            post :create, params: params
          end.not_to change(Note, :count)

          expect(response).to be_ok
          expect(response).to render_template :index
        end
      end
    end
  end

  describe "#index" do
    let(:client) { create :client, vita_partner: organization }
    let(:params) { { client_id: client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as a logged in user loading a clients notes" do
      before do
        sign_in user
        create :note # unrelated note
        create :system_note # unrelated system note
      end

      context "with an existing note" do
        let!(:system_note) { create :system_note, client: client, created_at: DateTime.new(2020, 9, 3) }
        let!(:client_note) { create :note, client: client, created_at: DateTime.new(2020, 10, 3) }

        it "renders a form" do
          get :index, params: params
          expect(assigns(:note)).to be_a(Note)
        end
      end

      context "loads notes" do
        before do
          allow(NotesPresenter).to receive(:grouped_notes).with(client).and_return({})
        end

        let(:user) { create :user, timezone: "America/Los_Angeles" }

        it "assigns grouped notes for use in template" do
          get :index, params: params
          expect(NotesPresenter).to have_received(:grouped_notes).with(client)
          expect(assigns(:all_notes_by_day)).not_to be_nil
        end
      end
    end
  end
end
