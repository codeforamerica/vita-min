require "rails_helper"

RSpec.feature "Client wants to file on their own" do
  scenario "a new client files through TaxSlayer", :flow_explorer_screenshot do
    ExperimentService.ensure_experiments_exist_in_database
    Experiment.update_all(enabled: true)

    allow(MixpanelService).to receive(:send_event)
    visit "/diy"
    # TODO: Find out if we are keeping the /diy page
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: "File taxes on your own")
    fill_in "Preferred first name", with: "Gary"
    fill_in "Email", with: "example@example.com"
    select "Yes", from: "Did you receive a 1099 tax form?"
    select "I filed every year", from: "In the last 4 years, how often have you filed?"
    # TODO: Replace with I18n keys
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: "Get support while you file on your own!")

    # TODO: Check taxslayer opens in new tab
    # new_window = page.window_opened_by do
    #   click_on I18n.t('general.continue')
    # end
    #
    # page.within_window(new_window) do
    #   puts URI.parse(current_url)
    # end


    experiment = Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT)
    experiment_particpant = ExperimentParticipant.find_by(record: DiyIntake.last, experiment: experiment)
    expect(experiment_particpant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)
  end
end
