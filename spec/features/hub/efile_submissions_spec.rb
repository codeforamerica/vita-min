require "rails_helper"

RSpec.describe "efile submissions" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:current_tax_year) { TaxReturn.current_tax_year }
      let!(:new_submission) { create :efile_submission, irs_submission_id: "12345200202011234567", tax_return: create(:tax_return, year: current_tax_year) }
      let!(:old_submission) { create :efile_submission, irs_submission_id: "12345200202011234568", tax_return: create(:tax_return, year: current_tax_year - 1) }

      before { login_as current_user }

      describe 'viewing the efile dashboard' do
        it 'only shows efile submissions from the current tax year' do
          visit hub_efile_submissions_path
          expect(page).to have_text new_submission.irs_submission_id
          expect(page).not_to have_text old_submission.irs_submission_id
        end
      end
    end
  end
end
