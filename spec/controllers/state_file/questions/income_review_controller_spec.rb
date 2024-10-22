require "rails_helper"

RSpec.describe StateFile::Questions::IncomeReviewController do
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
  before do
    sign_in intake
  end

  describe "unemployment card" do
    render_views
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
          get :edit

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
          get :edit

          expect(response.body).to have_text "Unemployment benefits (1099-G)"
          expect(response.body).to have_text "State info to be collected"
        end
      end
    end

    context "when they did not have unemployment income" do
      let(:fed_unemployment) { 0 }

      it "does not show the unemployment card" do
        get :edit

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
        get :edit
        expect(response.body).to have_text "Social Security benefits (SSA-1099)"
      end
    end

    context "they have _taxable_ social security benefit greater than zero" do
      let(:fed_ssb) { 0 }
      let(:fed_taxable_ssb) { 10 }
      it "shows the SSA card" do
        get :edit
        expect(response.body).to have_text "Social Security benefits (SSA-1099)"
      end
    end

    context "they have no social security benefit income" do
      let(:fed_ssb) { 0 }
      let(:fed_taxable_ssb) { 0 }

      it "doesn't show the SSA card" do
        get :edit
        expect(response.body).not_to have_text "Social Security benefits (SSA-1099)"
      end
    end
  end
end
