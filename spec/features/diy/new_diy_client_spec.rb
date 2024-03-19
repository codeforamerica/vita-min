require "rails_helper"

RSpec.feature "Client wants to file on their own" do
  let(:admin) { create :admin_user, name: "Admin the First" }

  before do
    Experiment.update_all(enabled: true)
    allow_any_instance_of(ExperimentService::TreatmentChooser).to receive(:choose).and_return :high
    FaqDatabaseExportService.export_yml_to_database
  end

  xscenario "a new client in the high-support experiment files through TaxSlayer", :flow_explorer_screenshot do
    allow(MixpanelService).to receive(:send_event)
    visit "/diy/file_yourself"

    expect(page).to have_selector("h1", text: I18n.t("diy.file_yourself.edit.title"))
    fill_in "Preferred first name", with: "Gary"
    fill_in "Email", with: "example@example.com"
    select "Yes", from: I18n.t("diy.file_yourself.edit.received_1099.label")
    select "I filed every year", from: "In the last 4 years, how often have you filed?"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("diy.continue_to_fsa.edit.title"))
    expect(find_link(I18n.t("general.continue"))[:target]).to eq("_blank")
    expect do
      if Capybara.current_driver == Capybara.javascript_driver
        taxslayer_window = window_opened_by do
          click_on I18n.t("general.continue")
        end
        taxslayer_window.close
      else
        click_on I18n.t("general.continue")
      end
    end.to have_enqueued_job(SendInternalEmailJob)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last

    chat_with_us_url = Nokogiri::HTML.parse(mail.html_part.body.to_s).css("a").find { |a| a["href"].include?('what_is_file_myself_and_how_does_it_work') }["href"]
    expect(chat_with_us_url).to include('diy_chat_with_us_token=')

    visit chat_with_us_url
    expect(DiyIntake.last.clicked_chat_with_us_at).to be_within(1.minute).of(Time.now)

    experiment = Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT)
    experiment_particpant = ExperimentParticipant.find_by(record: DiyIntake.last, experiment: experiment)
    expect(experiment_particpant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)

    login_as admin
    visit hub_admin_experiment_path(id: experiment)
    expect(table_contents(page.find('.participants-table'))).to include(hash_including({"outcome" => a_string_including(Time.now.year.to_s)}))
  end

  xscenario "a new client who goes through DIY after going through triage doesn't have to re-answer preferred name and filing frequency" do
    answer_gyr_triage_questions(choices: :defaults)
    click_on I18n.t("questions.triage.diy_tile.choose_diy")

    expect(page).to have_selector("h1", text: I18n.t("diy.file_yourself.edit.title"))
    expect(page).not_to have_field("Preferred first name")
    expect(page).not_to have_select("In the last 4 years, how often have you filed?")

    fill_in "Email", with: "example@example.com"
    select "Yes", from: I18n.t("diy.file_yourself.edit.received_1099.label")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("diy.continue_to_fsa.edit.title"))

    diy_intake = DiyIntake.last
    expect(diy_intake.preferred_first_name).to eq('Gary')
    expect(diy_intake.filing_frequency).to eq('not_filed')
  end
end
