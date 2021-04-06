require "rails_helper"

RSpec.describe Hub::NotesController, type: :controller do
  let(:organization) { create :organization }
  let(:client) { create :client, vita_partner: organization }
  let!(:intake) { create :intake, client: client }
  let(:timezone) { "America/New_York" }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: timezone) }
  let(:other_user) { create(:user) }
  describe "#create" do
    let(:mentions) { "" }
    let(:params) do
      {
        client_id: client.id,
        note: {
          body: "Note body",
          mentioned_ids: mentions
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      context "with mentions" do
        let(:mentions) { "#{user.id},#{other_user.id}" }
        it "creates a new note and saves notifications for mentioned users" do
          expect {
            post :create, params: params
          }.to change(client.notes, :count).by(1)
           .and change(UserNotification, :count).by(2)

          note = Note.last
          expect(note.body).to eq "Note body"
          expect(note.user).to eq user
          expect(user.notifications.last.notifiable).to eq note
          expect(other_user.notifications.last.notifiable).to eq note
          expect(response).to redirect_to hub_client_notes_path(client_id: client.id, anchor: "last-item")
        end
      end

      context "without mentioned users" do
        let(:mentions) { "" }
        it "creates a note without changing notifications length" do
          expect {
            post :create, params: params
          }.to change(client.notes, :count).by(1)
           .and not_change(user.notifications, :count)

          note = Note.last
          expect(note.body).to eq "Note body"
          expect(note.user).to eq user
        end
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

        context "when rendering HTML" do
          render_views

          it "adds a 'last-item' id attribute to the last note" do
            get :index, params: params

            last_note = Nokogiri::HTML.parse(response.body).css(".note:last-child").first
            expect(last_note.attr("id")).to eq "last-item"
          end
        end
      end

      context "loads notes" do
        let(:admin_user) { create :admin_user, name: "Penelope Persimmon" }
        let(:team_member) { create :team_member_user, name: "Mel Melon", site: (create :site, name: "Some Site") }
        before do

          allow(NotesPresenter).to receive(:grouped_notes).with(client).and_return({})
          allow(User).to receive(:taggable_for).with(client).and_return([team_member, admin_user])
        end

        let(:timezone) { "America/Los_Angeles" }

        it "assigns grouped notes for use in template" do
          get :index, params: params
          expect(NotesPresenter).to have_received(:grouped_notes).with(client)
          expect(assigns(:all_notes_by_day)).not_to be_nil
        end

        it "assigns taggable_users as stringified json" do
          get :index, params: params
          expect(User).to have_received(:taggable_for).with(client)
          expect(assigns(:taggable_users)).to eq "[{\"id\":#{team_member.id},\"name\":\"Mel Melon\",\"name_with_role_and_entity\":\"Mel Melon - Team Member - Some Site\"},{\"id\":#{admin_user.id},\"name\":\"Penelope Persimmon\",\"name_with_role_and_entity\":\"Penelope Persimmon - Admin\"}]"
        end
      end
    end
  end
end
