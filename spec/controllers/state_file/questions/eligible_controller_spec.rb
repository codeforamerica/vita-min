require "rails_helper"

describe StateFile::Questions::EligibleController do
  StateFile::StateInformationService.active_state_codes.excluding("ny").each do |state_code|
    it_behaves_like :df_data_required, false, state_code
  end

  let(:intake) { create :state_file_az_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text I18n.t("state_file.questions.eligible.edit.title1", year: MultiTenantService.statefile.current_tax_year, state: "Arizona")
    end

    context "AZ" do
      let(:intake) { create :state_file_az_intake }
  
      it "does not show NJ content, links to AZ FAQ" do
        get :edit
        expect(response.body.html_safe).to include I18n.t('state_file.questions.eligible.vita_option.want_to_claim_learn_more_html', link: "/en/az/faq/other_state_filing_options")
        expect(response.body.html_safe).not_to include("Get started with VITA now.")
        expect(response.body.html_safe).not_to include("Visit our FAQ")
        expect(response.body.html_safe).not_to include("Get connected now")
      end
    end

    context "NJ" do
      let(:intake) { create :state_file_nj_intake }
  
      it "shows vita_eligibility_reveal content and not connect_to_vita content" do
        get :edit
        expect(response.body.html_safe).to include("Get started with VITA now.")
        expect(response.body.html_safe).to include I18n.t('state_file.questions.eligible.vita_option.want_to_claim_learn_more_html', link: "/en/nj/faq/other_filing_options")
        expect(response.body.html_safe).not_to include("Visit our FAQ")
        expect(response.body.html_safe).not_to include("Get connected now")
      end
    end
  end
end
