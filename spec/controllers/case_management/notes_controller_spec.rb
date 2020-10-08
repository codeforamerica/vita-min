require 'rails_helper'

RSpec.describe CaseManagement::NotesController, type: :controller do
  let(:client) { create :client }

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
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

    context "as a logged in beta tester" do
      let(:current_user) { create :beta_tester }
      before do
        sign_in current_user
      end

      it "creates a new note" do
        post :create, params: params

        note = Note.last
        expect(note.body).to eq "Note body"
        expect(note.client).to eq client
        expect(note.user).to eq current_user
        expect(response).to redirect_to case_management_client_notes_path(client_id: client.id)
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
    let(:client) { create :client }
    let(:params) { { client_id: client.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "as a logged in user loading a clients notes" do
      before do
        sign_in(create :beta_tester)
        create :note # unrelated note
      end

      context "with an existing note" do
        render_views

        let!(:client_note) { create :note, client: client, created_at: DateTime.new(2020, 9, 3) }

        it "loads the users notes if there are any" do
          get :index, params: params

          expect(assigns(:notes)).to eq([client_note])
        end

        it "renders a form" do
          get :index, params: params

          html = Nokogiri::HTML.parse(response.body)
          form_element = html.at_css("form.note-form")
          expect(form_element["action"]).to eq(case_management_client_notes_path(client_id: client.id))
          message_record = Nokogiri::HTML.parse(response.body).at_css(".message--incoming")
          expect(message_record).to have_text("8:00 PM EDT")
        end

      end

      context "with notes from different days" do
        before do
          create :note, client: client, created_at: DateTime.new(2020, 10, 5, 0) # UTC
          create :note, client: client, created_at: DateTime.new(2019, 10, 5, 0)
        end

        it "correctly groups notes by day created" do
          get :index, params: params
          oct_4_2019_eastern = Time.new(2019, 10, 4).in_time_zone('America/New_York').beginning_of_day
          oct_4_2020_eastern = Time.new(2020, 10, 4).in_time_zone('America/New_York').beginning_of_day

          expect(assigns(:notes_by_day).keys.first).to eq oct_4_2019_eastern
          expect(assigns(:notes_by_day).keys.last).to eq oct_4_2020_eastern
        end
      end
    end
  end
end

