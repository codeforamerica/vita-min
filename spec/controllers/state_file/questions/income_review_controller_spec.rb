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

  describe "1099R" do
    render_views

    context "when there are state 1099Rs" do
      it "shows a summary of each" do
        primary_1099r = create(:state_file1099_r, intake: intake, payer_name: "Payeur", recipient_name: 'Prim Rose')
        spouse_1099r = create(:state_file1099_r, intake: intake, payer_name: "Payure", recipient_name: 'Sprout Vine')
        get :edit

        expect(response.body).to have_text "Retirement income (1099-R)"
        expect(response.body).to have_text "Payeur"
        expect(response.body).to have_text "Prim Rose"
        expect(response.body).to have_link(href: edit_retirement_income_path(id: primary_1099r.id))
        expect(response.body).to have_text "Payure"
        expect(response.body).to have_text "Sprout Vine"
        expect(response.body).to have_link(href: edit_retirement_income_path(id: spouse_1099r.id))
      end
    end

    context "when there are no 1099Rs" do
      it "does not show any information bout 1099Rs" do
        get :edit

        expect(response.body).not_to have_text "Retirement income (1099-R)"
      end
    end
  end
end