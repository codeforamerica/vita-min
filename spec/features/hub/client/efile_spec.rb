require "rails_helper"

RSpec.feature "View efile submissions for a client" do
  context "As an authenticated user" do
    let(:user) { create :admin_user }
    let(:client) { intake.client }
    let!(:intake) { create(:ctc_intake, preferred_name: "Glarg", product_year: Rails.configuration.product_year) }
    let!(:tax_return) { create(:tax_return, :ctc, client: client) }
    let!(:initial_efile_submission) { create :efile_submission, :failed, tax_return: tax_return }

    let(:resubmit_button_text) { "Resubmit" }

    before do
      login_as user
    end

    context "when the last efile submission was a failure" do
      it "allows resubmitting" do
        visit efile_hub_client_path(id: client.id)

        expect(page).to have_content(intake.preferred_name)
        expect(page).to have_button(resubmit_button_text)
      end

      context "for an old archived intake" do
        let!(:intake) { create(:archived_2021_ctc_intake) }

        it "does not allow resubmitting" do
          visit efile_hub_client_path(id: client.id)

          expect(page).to have_content(intake.preferred_name)
          expect(page).not_to have_button(resubmit_button_text)
        end
      end

      context "for a new archived intake" do
        before do
          intake.update(product_year: 2022)
        end

        it "does not allow resubmitting" do
          visit efile_hub_client_path(id: client.id)

          expect(page).to have_content(intake.preferred_name)
          expect(page).not_to have_button(resubmit_button_text)
        end
      end
    end
  end
end
