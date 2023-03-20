require "rails_helper"

RSpec.feature "Client wants to file on their own" do
  scenario "a new client files through TaxSlayer", :flow_explorer_screenshot do
    ExperimentService.ensure_experiments_exist_in_database
    Experiment.update_all(enabled: true)

    allow(MixpanelService).to receive(:send_event)
    # TODO: Once /diy redirect goes away, visit /diy/file_yourself directly
    visit "/diy"

    expect(page).to have_selector("h1", text: "File taxes on your own")
    fill_in "Preferred first name", with: "Gary"
    fill_in "Email", with: "example@example.com"
    select "Yes", from: "Did you receive a 1099 tax form?"
    select "I filed every year", from: "In the last 4 years, how often have you filed?"
    # TODO: Replace with I18n keys
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: "Get support while you file on your own!")
    expect(page).to have_selector('a[href="https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934"][target="_blank"]')

    experiment = Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT)
    experiment_particpant = ExperimentParticipant.find_by(record: DiyIntake.last, experiment: experiment)
    expect(experiment_particpant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)
  end
end
