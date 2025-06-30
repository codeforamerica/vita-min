require "rails_helper"

RSpec.feature "Document Help Flow", :flow_explorer_screenshot, active_job: true do
  let(:client) do
    create :client,
           intake: (build :intake, bought_marketplace_health_insurance: "yes", had_retirement_income: "yes", sms_notification_opt_in: "yes", sms_phone_number: "+15105551234")
  end
  let(:user) { create(:admin_user) }
  before do
    login_as client, scope: :client
    login_as user, scope: :user
  end

  scenario "getting through documents flow with help pages" do
    visit "documents/ids"
    expect(page).to have_text I18n.t('views.documents.ids.title.one')

    click_on I18n.t('views.layouts.document_upload.dont_have')
    expect(page).to have_text I18n.t('documents.documents_help.show.header')
    expect do
      click_on I18n.t('documents.documents_help.show.reminder_link')
    end.to change(OutgoingTextMessage, :count).by(1)
    expect(page).to have_text I18n.t('documents.reminder_link.notice')
    expect(page).to have_text I18n.t('views.documents.ssn_itins.title')

    click_on I18n.t('views.layouts.document_upload.dont_have')
    expect do
      click_on I18n.t('documents.documents_help.show.cant_get')
    end.to change(SystemNote::DocumentHelp, :count).by(1)
    expect(page).to have_text I18n.t('documents.updated_specialist.notice')
    expect(page).to have_text I18n.t('views.documents.intro.title')
    click_on I18n.t('general.continue')
    expect(page).to have_text I18n.t('views.documents.form1095as.title')

    click_on I18n.t('views.layouts.document_upload.dont_have')
    expect do
      click_on I18n.t('documents.documents_help.show.doesnt_apply')
    end.to change(SystemNote::DocumentHelp, :count).by(1)
  end

  scenario "need help finding ID card" do
    # navigating as client
    visit "documents/ids"
    expect(page).to have_text I18n.t('views.documents.ids.title.one')

    click_on I18n.t('views.layouts.document_upload.dont_have')
    expect(page).to have_text I18n.t('documents.documents_help.show.header')
    expect do
      click_on I18n.t("documents.documents_help.show.need_help_find")
    end.to change(SystemNote::DocumentHelp, :count).by(1)

    # viewing notes in the hub
    visit hub_client_notes_path(client_id: client.id)
    expect(page).to have_text "Add a note"
    expect(page).to have_text I18n.t("hub.system_notes.custom_help_message.ID")
  end
end
