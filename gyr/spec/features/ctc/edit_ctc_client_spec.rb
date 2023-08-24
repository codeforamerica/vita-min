require "rails_helper"

RSpec.describe "a user editing a clients intake fields", requires_default_vita_partners: true do
  describe "ctc intakes" do
    context "as an admin user" do
      let(:user) { create :admin_user }

      before do
        # Create a CTC intake in a realistic way, then clear cookies
        allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
        complete_intake_through_code_verification
        allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(false)

        Capybara.current_session.reset!
      end

      it "can see clients created through CTC intake with their current status" do
        new_client = Client.last

        login_as user

        visit hub_client_path(id: new_client)

        within ".tax-return-list" do
          expect(page).to have_text MultiTenantService.new(:ctc).current_tax_year
          expect(page).to have_text I18n.t('hub.tax_returns.status.intake_in_progress')
        end
      end
    end
  end
end
