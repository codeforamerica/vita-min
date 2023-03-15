require "rails_helper"

RSpec.feature "Client wants to file on their own" do
  scenario "a new client files through TaxSlayer", :flow_explorer_screenshot do
    ExperimentService.ensure_experiments_exist_in_database
    Experiment.update_all(enabled: true)

    allow(MixpanelService).to receive(:send_event)
    visit "/diy"
    expect(page).to have_selector("h1", text: "File taxes on your own")
    fill_in "Preferred first name", with: "Gary"
    fill_in "Email", with: "example@example.com"
    click_on I18n.t('general.continue')

    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.file_yourself.edit.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.email.edit.title'))
    fill_in I18n.t("views.questions.email_address.email_address"), with: "example@example.com"
    fill_in I18n.t("views.questions.email_address.email_address_confirmation"), with: "example@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.continue_to_fsa.edit.title'))
    expect(page).to have_text(I18n.t('diy.continue_to_fsa.edit.continue_to_tax_slayer'))

    experiment = Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT)
    experiment_particpant = ExperimentParticipant.find_by(record: DiyIntake.last, experiment: experiment)
    expect(experiment_particpant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)
  end
end
