require "rails_helper"

RSpec.feature "Visit State File coming soon page" do
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "before the StateFile launch time (state_file_start_of_open_intake)" do
    let(:fake_time_before_launch) { Time.utc(2023, 12, 22, 0, 0, 0) }

    it "redirects to the coming-soon page" do
      Timecop.freeze(fake_time_before_launch) do
        visit "/"
      end

      expect(page).to have_text I18n.t('state_file.state_file_pages.coming_soon.title')
    end
  end

  context "visiting the coming soon page after StateFile launch time (state_file_start_of_open_intake)" do
    let(:fake_time_after_launch) { Time.utc(2024, 1, 2, 0, 0, 0) } # only for non-prod, in prod this date is set to 2/5/2024 8am
    it "redirects to the home page" do
      Timecop.freeze(fake_time_after_launch) do
        visit "/coming-soon"
      end

      expect(page).to have_text I18n.t('state_file.state_file_pages.about_page.header')
    end
  end

  # can vist the session toggles page
  # can visit the hub
end
