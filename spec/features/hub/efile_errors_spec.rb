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
          click_on I18n.t('general.save')

          expect(efile_error.reload).to be_auto_cancel
        end
      end
    end
  end
end
