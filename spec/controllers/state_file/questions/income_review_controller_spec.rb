require "rails_helper"

RSpec.describe StateFile::Questions::IncomeReviewController do
  StateFile::StateInformationService.active_state_codes.excluding("ny", "nj").each do |state_code|
    it_behaves_like :df_data_required, true, state_code
  end
  it_behaves_like :df_data_required, false, :nj

  let(:primary_first_name) { "Filer" }
  let(:primary_last_name) { "Oftaxes" }
  let(:spouse_first_name) { "Mary" }
  let(:spouse_last_name) { "Taxfiler" }
  let(:intake) do
    create(
      :state_file_az_intake,
      filing_status: :married_filing_jointly,
      primary_first_name: primary_first_name,
      primary_last_name: primary_last_name,
      spouse_first_name: spouse_first_name,
      spouse_last_name: spouse_last_name
    )
  end
  let(:params) do
    { state_file_income_review_form: {
      device_id: device_id
    } }
  end
  let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }
  let(:device_id) { "ABC123" }
  before do
    sign_in intake
  end
  render_views

  describe ".show?" do
    context "when there is no income" do

      before do
        intake.direct_file_data.fed_unemployment = 0
        intake.direct_file_data.fed_ssb = 0
        intake.direct_file_data.fed_taxable_ssb = 0

        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
      end

      it "does not show the page" do
        expect(described_class).not_to be_show(intake)
      end
    end
  end

  describe "#update" do
    context "income form validity" do
      let(:mock_next_path) { root_path }
      before do
        allow(subject).to receive(:next_path).and_return mock_next_path
      end

      shared_examples "shows error and does not proceed" do
        it "shows error and does not proceed" do
          post :update, params: params
          expect(response).to render_template(:edit)
          expect(response.body).to have_text I18n.t("state_file.questions.income_review.edit.invalid_income_form_error")
        end
      end

      shared_examples "proceeds as if there are no errors" do
        it "proceeds as if there are no errors" do
          post :update, params: params
          expect(response.body).not_to have_text I18n.t("state_file.questions.income_review.edit.invalid_income_form_error")
          expect(response).to redirect_to mock_next_path
        end
      end

      context "with W-2s with missing state wages" do
        let(:intake) { create(:state_file_nj_intake) }
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, state_wages_amount: 0, state_income_tax_amount: 0) }
        include_examples "shows error and does not proceed"
      end
      
      context "with W-2s having invalid Box 14 values" do
        let(:intake) { create(:state_file_nj_intake) }
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: 200) }

        include_examples "shows error and does not proceed"
      end

      context "with W-2s having valid Box 14 values" do
        let(:intake) { create(:state_file_nj_intake) }
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: 100) }

        include_examples "proceeds as if there are no errors"
      end

      context "with W-2s having valid Box 16 values" do
        let(:intake) { create(:state_file_nj_intake) }
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, wages: 0, state_wages_amount: 0, state_income_tax_amount: 0) }

        include_examples "proceeds as if there are no errors"
      end

      context "with 1099rs having invalid Box 14 values" do
        let(:intake) { create(:state_file_md_intake) }
        let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, gross_distribution_amount: 500, state_tax_withheld_amount: 550) }

        include_examples "shows error and does not proceed"
      end
    end
  end

  describe "W-2s card" do
    before(:each) do
      StateFileW2.delete_all
    end

    shared_examples "does not display W2 warnings" do
      it "does not display W2 warnings" do
        get :edit, params: params
        expect(response.body).not_to have_text I18n.t("state_file.questions.income_review.edit.warning")
      end
    end

    shared_examples "displays one W2 warning" do
      it "displays one W2 warning" do
        get :edit, params: params
        expect(response.body.scan(I18n.t("state_file.questions.income_review.edit.warning")).size).to eq(1)
      end
    end

    context "when there are no w2s" do
      it "does not show the card" do
        get :edit, params: params

        expect(response.body).not_to have_text "Jobs (W-2)"
      end
    end

    context "when there are w2s" do
      let!(:state_file_w2_1) { create :state_file_w2, employee_name: "Egg Person", employer_name: "First Enterprises", state_file_intake: intake }
      let!(:state_file_w2_2) { create :state_file_w2, employee_name: "Chicken Person", employer_name: "First Corporation", state_file_intake: intake }

      it "shows a summary of each W2" do
        get :edit, params: params

        expect(response.body).to have_text "Jobs (W-2)"
        expect(response.body).to have_text "Egg Person"
        expect(response.body).to have_text "Chicken Person"
        expect(response.body).to have_link(href: edit_w2_path(id: state_file_w2_1.id))
        expect(response.body).to have_text "First Enterprises"
        expect(response.body).to have_text "First Corporation"
        expect(response.body).to have_link(href: edit_w2_path(id: state_file_w2_2.id))
      end
    end

    context "when no W2 box 14 warnings" do
      let(:intake) { create(:state_file_nj_intake) }

      context "when not in a state that requires ui_wf_swf or fli Box 14 values" do
        let(:intake) { create(:state_file_az_intake) }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake) }
        include_examples "does not display W2 warnings"
      end

      context "when no w2s" do
        include_examples "does not display W2 warnings"
      end

      context "when only one w2 and box14_ui_wf_swf is not present" do
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "does not display W2 warnings"
      end

      context "when only one w2 and fli is not present" do
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT) }
        include_examples "does not display W2 warnings"
      end

      context "when there are two w2s where box14_ui_wf_swf is not present but they have different filers" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:primary_ssn_from_fixture) { intake.primary.ssn }
        let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "does not display W2 warnings"
      end

      context "when there are two w2s where fli is not present but they have different filers" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:primary_ssn_from_fixture) { intake.primary.ssn }
        let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT) }
        include_examples "does not display W2 warnings"
      end

      context "when two or more w2s and box14_ui_wf_swf and fli are valid on both" do
        let!(:state_file_w2_1) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        let!(:state_file_w2_2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "does not display W2 warnings"
      end
    end

    context "when W2 box 14 warnings are present" do
      let(:intake) { create(:state_file_nj_intake) }

      context "when primary has two W2s and box14_ui_wf_swf is not present in one" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:primary_ssn_from_fixture) { intake.primary.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when secondary has two W2s and box14_ui_wf_swf is not present in one" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when box14_ui_wf_swf is too high" do
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_ABOVE_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when primary has two W2s and fli is not present in one" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:primary_ssn_from_fixture) { intake.primary.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when secondary has two W2s and fli is not present in one" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
        let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT) }
        let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_wf_swf: NjTestConstHelper::UI_WF_SWF_AT_LIMIT, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when fli is too high" do
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_fli: NjTestConstHelper::FLI_ABOVE_LIMIT) }
        include_examples "displays one W2 warning"
      end

      context "when a single W2 has values in both UI/HC/WD and UI/WF/SWF" do
        let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_ui_wf_swf: 10, box14_ui_hc_wd: 10, box14_fli: NjTestConstHelper::FLI_AT_LIMIT) }
        include_examples "displays one W2 warning"
      end
    end

    context "when W2 box 16 warnings are present in NJ" do
      let(:intake) { create(:state_file_nj_intake) }
      let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, state_wages_amount: 0, state_income_tax_amount: 0) }
      include_examples "displays one W2 warning"
    end

    context "when W2 box 16 warnings are not present due to not being in NJ" do
      let(:intake) { create(:state_file_az_intake) }
      let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, state_wages_amount: 0, state_income_tax_amount: 0) }
      include_examples "does not display W2 warnings"
    end

    context "when W2 box 16 warnings are not present due to wages being 0" do
      let(:intake) { create(:state_file_nj_intake) }
      let!(:state_file_w2) { create(:state_file_w2, state_file_intake: intake, wages: 0, state_wages_amount: 0, state_income_tax_amount: 0) }
      include_examples "does not display W2 warnings"
    end
  end

  describe "unemployment card" do
    before do
      intake.direct_file_data.fed_unemployment = fed_unemployment
      intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
    end

    context "when they had unemployment income" do
      let(:fed_unemployment) { 1000 }

      context "when there are state 1099Gs" do
        it "shows a summary of each" do
          primary_1099g = create(:state_file1099_g, intake: intake, payer_name: "Payeur", recipient: :primary)
          spouse_1099g = create(:state_file1099_g, intake: intake, payer_name: "Payure", recipient: :spouse)
          get :edit, params: params

          expect(response.body).to have_text "Unemployment benefits (1099-G)"
          expect(response.body).to have_text "Payeur"
          expect(response.body).to have_text "Filer Oftaxes"
          expect(response.body).to have_link(href: edit_unemployment_path(id: primary_1099g.id))
          expect(response.body).to have_text "Payure"
          expect(response.body).to have_text "Mary Taxfiler"
          expect(response.body).to have_link(href: edit_unemployment_path(id: spouse_1099g.id))
        end
      end

      context "when there are no 1099Gs" do
        it "shows a message" do
          get :edit, params: params

          expect(response.body).to have_text "Unemployment benefits (1099-G)"
          expect(response.body).to have_text "State info to be collected"
        end
      end
    end

    context "when they did not have unemployment income" do
      let(:fed_unemployment) { 0 }

      it "does not show the unemployment card" do
        get :edit, params: params

        expect(response.body).not_to have_text "Unemployment benefits (1099-G)"
      end
    end
  end

  describe "SSA-1099 card" do
    render_views
    before do
      intake.direct_file_data.fed_ssb = fed_ssb
      intake.direct_file_data.fed_taxable_ssb = fed_taxable_ssb
      intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
    end

    context "they have social security benefits greater than zero" do
      let(:fed_ssb) { 10 }
      let(:fed_taxable_ssb) { 0 }
      it "shows the SSA card" do
        get :edit, params: params
        expect(response.body).to have_text "Social Security benefits (SSA-1099)"
      end
    end

    context "they have _taxable_ social security benefit greater than zero" do
      let(:fed_ssb) { 0 }
      let(:fed_taxable_ssb) { 10 }
      it "shows the SSA card" do
        get :edit, params: params
        expect(response.body).to have_text "Social Security benefits (SSA-1099)"
      end
    end

    context "they have no social security benefit income" do
      let(:fed_ssb) { 0 }
      let(:fed_taxable_ssb) { 0 }

      it "doesn't show the SSA card" do
        get :edit, params: params
        expect(response.body).not_to have_text "Social Security benefits (SSA-1099)"
      end
    end
  end

  describe "1099R card" do
    render_views

    shared_examples "does not display 1099R warning" do
      it "has no warnings" do
        get :edit, params: params
        expect(response.body).not_to have_text I18n.t("state_file.questions.income_review.edit.warning")
      end
    end

    shared_examples "displays one 1099R warning" do
      it "displays warning in 1099R card" do
        get :edit, params: params
        expect(response.body.scan(I18n.t("state_file.questions.income_review.edit.warning")).size).to eq(1)
      end
    end

    context "when there are state 1099Rs" do
      context "when 1099Rs are valid" do
        let!(:primary_1099r) { create(:state_file1099_r, intake: intake, payer_name: "Payeur", recipient_name: "Prim Rose") }
        let!(:spouse_1099r) { create(:state_file1099_r, intake: intake, payer_name: "Payure", recipient_name: "Sprout Vine") }

        it_behaves_like "does not display 1099R warning"

        it "shows a summary of each" do
          get :edit, params: params

          expect(response.body).to have_text "Retirement income (1099-R)"
          expect(response.body).to have_text "Payeur"
          expect(response.body).to have_text "Prim Rose"
          expect(response.body).to have_link(href: edit_retirement_income_path(id: primary_1099r.id))
          expect(response.body).to have_text "Payure"
          expect(response.body).to have_text "Sprout Vine"
          expect(response.body).to have_link(href: edit_retirement_income_path(id: spouse_1099r.id))
        end
      end

      context "when a 1099R is blocking-invalid" do
        let!(:invalid_1099r) { create(:state_file1099_r, intake: intake, gross_distribution_amount: 500, state_tax_withheld_amount: 550) }

        it_behaves_like "displays one 1099R warning"
      end

      context "when a 1099R is nonblocking-invalid" do
        let!(:invalid_1099r) { create(:state_file1099_r, intake: intake, payer_state_identification_number: "123456789asdfghjklqwertyuiop") }

        it_behaves_like "does not display 1099R warning"
      end
    end

    context "when there are no 1099Rs" do
      it "does not show any information bout 1099Rs" do
        get :edit, params: params

        expect(response.body).not_to have_text "Retirement income (1099-R)"
      end
    end
  end

  describe "1099-INT card" do
    render_views

    context "when filer has no 1099-INT" do
      it "does not show the interest income card" do
        get :edit, params: params
        expect(response.body).not_to have_text "Interest income (1099-INT)"
      end
    end

    context "when filer has 1099-INT info in json" do
      let(:intake) do
        create(:state_file_md_intake, :df_data_1099_int)
      end

      it "shows the interest income card" do
        get :edit, params: params
        expect(response.body).to have_text "Interest income (1099-INT)"
      end
    end
  end

  context "without device id information due to JS being disabled" do
    let(:device_id) { nil }

    it "flashes an alert and does re-renders edit" do
      post :update, params: params
      expect(flash[:alert]).to eq(I18n.t("general.enable_javascript"))
    end
  end

  context "with device id" do
    it "updates device id" do
      post :update, params: params
      expect(efile_device_info.reload.device_id).to eq "ABC123"
    end
  end
end
