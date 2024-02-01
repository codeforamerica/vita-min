require "rails_helper"

RSpec.feature "View state-file efile submissions page in hub" do
  context "As an authenticated state file admin user" do
    let(:user) { create :state_file_admin_user }
    let!(:efile_submission) { create :efile_submission, :for_state}

    before do
      login_as user
    end

    it "shows efile submission status, submission ids, data source type and id" do
      visit hub_state_file_efile_submissions_path

      expect(page).to have_content(efile_submission.id)
      expect(page).to have_content(efile_submission.current_state.humanize(capitalize: false))
      expect(page).to have_content(efile_submission.irs_submission_id)
      expect(page).to have_content(efile_submission.data_source.state_name)
      expect(page).to have_content(efile_submission.data_source.email_address)
    end

    context "when before state file launch" do
      let(:fake_time_before_launch) { Time.utc(2023, 12, 22, 0, 0, 0) }

      it "does not redirect hub pages to coming-soon page" do
        Timecop.freeze(fake_time_before_launch) do
          visit hub_state_file_efile_submissions_path
        end

        expect(page).not_to have_text I18n.t('state_file.state_file_pages.coming_soon.title')
      end
    end
  end
end
