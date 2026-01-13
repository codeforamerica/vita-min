require "rails_helper"

RSpec.feature "View and add internal notes for a client" do
  context "As an authenticated user" do
    let(:organization) { create :organization }
    let(:site) { create(:site, parent_organization: organization) }
    let(:user) { create :user, timezone: "America/Los_Angeles", role: create(:organization_lead_role, organization: organization) }
    let!(:tagged_user) { create :user, timezone: "America/Los_Angeles", role: create(:site_coordinator_role, sites: [site]) }
    let!(:documents) { create_list(:document, 3, created_at: DateTime.new(2020, 3, 1).utc, document_type: "Employment", uploaded_by: client, client: client) }
    let!(:not_included_docs) { create_list(:document, 2, created_at: DateTime.new(2020, 3,1).utc, uploaded_by: user, client: client) }
    let(:client) { create :client, vita_partner: site, intake: build(:intake, preferred_name: "Bart Simpson") }
    before do
      login_as user
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:hub_email_notifications).and_return(true)
      allow(BedrockDocScreener).to receive(:screen_document!).and_return(["{}", "{}"])
    end

    scenario "add an internal note to a client" do
      visit hub_client_notes_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_text("4:00 PM") # 4:00 PM Pacific is midnight UTC; the note is created at midnight UTC
      expect(page).to have_text("Client added 3 documents.")
      fill_in "Add a note", with: "Some pertinent info, presumably"
      click_on "Save"

      new_note = Note.last
      expect(new_note.client).to eq client
      expect(new_note.user).to eq user
    end

    scenario "tagging a user", :js do
      visit hub_client_notes_path(client_id: client.id)
      expect(page).not_to have_css(".tagify__dropdown")
      input = find('span.tagify__input')
      input.click
      input.send_keys("@")
      expect(page).to have_css(".tagify__dropdown")
      all_tagging_options = all("div.tagify__dropdown__wrapper div")
      expect(all_tagging_options.map(&:text)).to match_array [user.name_with_role_and_entity, tagged_user.name_with_role_and_entity]
      other_user_option = find("div.tagify__dropdown__wrapper div", text: tagged_user.name_with_role_and_entity)
      other_user_option.click
      expect(input).to have_text tagged_user.name_with_role
      click_on "Save"

      note = find(".note#last-item")
      expect(note).to have_text "@#{tagged_user.name_with_role}"
      # creates UserNotification
      expect(tagged_user.notifications.last.notifiable_type).to eq "Note"
      # sends tagged user an email
      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq [tagged_user.email]
      expect(mail.subject).to eq "Tagged in a note for GetYourRefund Client ##{client.id}"
    end
  end
end