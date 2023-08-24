require "rails_helper"

RSpec.describe "efile errors" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let!(:efile_error) { create :efile_error, code: "CANCEL-ME-123" }

      before { login_as current_user }

      describe 'editing an error' do
        it 'allows an error to be classified as auto cancellable' do
          visit hub_efile_errors_path
          click_on efile_error.code
          click_on I18n.t('general.edit')
          check "Auto-cancel?"
          check "Auto-wait?"
          click_on I18n.t('general.save')

          within ".test-auto-cancel" do
            expect(page).to have_selector("img[alt='yes']")
          end

          within ".test-auto-wait" do
            expect(page).to have_selector("img[alt='yes']")
          end
        end
      end
    end
  end
end
