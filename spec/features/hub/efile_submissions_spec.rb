require "rails_helper"

RSpec.describe "efile submissions" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:current_tax_year) { TaxReturn.current_tax_year }
      let!(:new_submission) { create :efile_submission, irs_submission_id: "12345200202011234567", tax_return: create(:tax_return, year: current_tax_year) }
      let!(:old_submission) { create :efile_submission, irs_submission_id: "12345200202011234568", tax_return: create(:tax_return, year: current_tax_year - 1) }
      let!(:rejected_submission) { create(:efile_submission, :rejected, :ctc, :with_errors, tax_return: build(:tax_return, year: current_tax_year)) }

      before { login_as current_user }

      describe 'viewing the efile dashboard' do
        it 'only shows efile submissions from the current tax year' do
          visit hub_efile_submissions_path
          expect(page).to have_text new_submission.irs_submission_id
          expect(page).not_to have_text old_submission.irs_submission_id
        end

        it "shows the reject codes for rejected efile submissions" do
          visit hub_efile_submissions_path

          error_1 = EfileError.where(code: "IND-189").first
          error_2 = EfileError.where(code: "IND-190").first
          html = Nokogiri::HTML.parse(page.body)

          expect(page).to have_text error_1.code
          expect(html.at_css(".error-#{error_1.id}.tooltip").attr("title"))
            .to eq("'DeviceId' in 'AtSubmissionCreationGrp' in 'FilingSecurityInformation' in the Return Header must have a value.")
          expect(page).to have_link(href: hub_efile_error_path(id: error_1.id))

          expect(page).to have_text error_2.code
          expect(html.at_css(".error-#{error_2.id}.tooltip").attr("title"))
            .to eq("'DeviceId' in 'AtSubmissionFilingGrp' in 'FilingSecurityInformation' in the Return Header must have a value.")
          expect(page).to have_link(href: hub_efile_error_path(id: error_2.id))
        end
      end
    end
  end
end
