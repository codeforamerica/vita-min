require "rails_helper"

describe Ctc::Questions::ConfirmInformationController do
  let(:intake) { create(:client_with_ctc_intake_and_return).intake  }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated client" do
      before do
        sign_in intake.client
      end

      context "when rendering templates" do
        render_views

        context "when the TIN type is SSN" do
          let(:intake) do
            create(
              :client_with_intake_and_return,
              intake: create(:ctc_intake, tin_type: "ssn", primary_last_four_ssn: "1234")
            ).intake
          end

          it "shows SSN labels" do
            get :edit

            expect(response_html.at_css(".review-box__body div:last-child")).to have_text "SSN: XXX-XX-1234"
          end
        end

        context "when the TIN type is ITIN" do
          let(:intake) do
            create(
              :client_with_intake_and_return,
              intake: create(:ctc_intake, tin_type: "itin", primary_last_four_ssn: "1234")
            ).intake
          end

          it "shows ITIN labels" do
            get :edit

            expect(response_html.at_css(".review-box__body div:last-child")).to have_text "ITIN: XXX-XX-1234"
          end
        end

        context "when not filing joint" do
          let(:intake) { create :ctc_intake }
          let!(:tax_return) { create :tax_return, filing_status: "single", client: intake.client }

          it "does not show the spouse info" do
            get :edit

            expect(response_html).not_to have_text "Your spouse"
          end

          it "does not show a field for the spouse's pin" do
            get :edit

            expect(response_html.css(".form-group input").length).to eq 1
          end
        end

        context "when filing joint" do
          let(:intake) { create :ctc_intake, spouse_first_name: "Gorby", spouse_last_name: "Pants" }
          let!(:tax_return) { create :tax_return, filing_status: "married_filing_jointly", client: intake.client }

          it "shows the spouse info" do
            get :edit

            expect(response_html).to have_text "Your spouse"
          end

          it "shows a field for the spouse's PIN" do
            get :edit

            expect(response_html).to have_text "Gorby Pants's five digit PIN"
            expect(response_html.css(".form-group input").length).to eq 2
          end

          context "when the spouse has an ITIN" do
            let(:intake) { create :ctc_intake, spouse_tin_type: "itin", spouse_last_four_ssn: "1234" }

            it "properly displays the ITIN" do
              get :edit

              expect(response_html.at_css(".review-box__body.spouse-info div:last-child")).to have_text "ITIN: XXX-XX-1234"
            end
          end
        end

        context "without dependents" do
          it "does not show dependents section" do
            get :edit

            expect(response_html).not_to have_text "Your dependents"
          end
        end

        context "with dependents" do
          before do
            create :qualifying_relative, intake: intake, tin_type: "ssn", ssn: "111887777"
            create :qualifying_child, intake: intake, tin_type: "atin", ssn: "666554444"
            create :nonqualifying_dependent, intake: intake, first_name: "Donnie", last_name: "Dependent"
          end

          it "shows dependents' info for qualifying dependents only" do
            get :edit

            dependents_html = response_html.at_css(".dependents-info")
            expect(dependents_html).to have_text "Your dependents"
            expect(dependents_html.at_css("li:first-child")).to have_text "SSN: XXX-XX-7777"
            expect(dependents_html.at_css("li:nth-child(2)")).to have_text "ATIN: XXX-XX-4444"
            expect(dependents_html).not_to have_text "Donnie Dependent"
          end
        end

        context "when not using direct deposit" do
          let(:intake) do
            create(
              :client_with_intake_and_return,
              intake: create(:ctc_intake, refund_payment_method: "check")
            ).intake
          end

          it "does not display bank information" do
            get :edit

            expect(response_html).not_to have_text "Your bank information"
          end
        end

        context "when using direct deposit" do
          let(:intake) do
            create(
              :client_with_intake_and_return,
              intake: create(:ctc_intake, refund_payment_method: "direct_deposit", bank_account: create(:bank_account))
            ).intake
          end

          it "shows bank information" do
            get :edit

            expect(response_html).to have_text "Your bank information"
          end
        end
      end
    end
  end

  describe '#update' do
    it_behaves_like :a_post_action_for_authenticated_ctc_clients_only, action: :update
  end
end