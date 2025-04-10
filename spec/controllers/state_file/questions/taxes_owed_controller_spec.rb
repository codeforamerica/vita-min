require "rails_helper"

describe StateFile::Questions::TaxesOwedController do
  let(:filing_year) { MultiTenantService.new(:statefile).current_tax_year + 1 }
  let(:minute_before_tax_day) { DateTime.new(filing_year, 4, 14, 23, 59) }

  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    context 'az' do
      let(:intake) { create :state_file_az_owed_intake }
      it 'succeeds' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).not_to have_text "Here is more information about tax due dates"
        expect(response_html).to have_text "Routing Number"
      end
    end

    context 'nj' do
      let(:intake) { create(:state_file_nj_intake) }
      it 'succeeds' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).to have_text "Here is more information about tax due dates"
        expect(response_html).to have_text "Routing Number"
      end

      context 'when taxpayer owes more than 400$ in taxes' do
        let(:intake) { create(:state_file_nj_intake, :df_data_taxes_owed) }
        it 'displays the underpayment notice' do
          get :edit
          expect(response).to be_successful
          expect(response_html).to have_text "This can happen for many reasons, but common ones are"
        end
      end

      context 'when taxpayer owes less than 400$ in taxes' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it 'does not display the underpayment notice' do
          get :edit
          expect(response).to be_successful
          expect(response_html).not_to have_text "This can happen for many reasons, but common ones are"
        end
      end
    end

    StateFile::StateInformationService.active_state_codes.excluding("ny").each do |state_code|
      describe "when paying with direct deposit in #{state_code}" do
        let(:intake) { create "state_file_#{state_code}_intake".to_sym }
        let(:timezone) { StateFile::StateInformationService.timezone(state_code) }
        let(:payment_deadline_date) { StateFile::StateInformationService.payment_deadline_date(state_code) }
        let(:utc_offset_hours) { minute_before_tax_day.in_time_zone(timezone).utc_offset / 1.hour }
        let(:minute_before_tax_day_local) { minute_before_tax_day - utc_offset_hours.hours }
        let(:stringified_deadline) { payment_deadline_date.strftime("%B #{payment_deadline_date.day.ordinalize}, %Y") }

        context "when form is viewed before April 15th" do
          around do |example|
            Timecop.freeze(minute_before_tax_day_local) do
              example.run
            end
          end

          it "shows the withdrawal date selector and does not explain when your payment will be withdrawn" do
            get :edit
            expect(response).to be_successful
            expect(response_html).to have_text(
              "When would you like the funds withdrawn from your account? (must be on or before #{stringified_deadline}):"
            )
            expect(response_html).not_to have_text(
              "Because you are submitting your return on or after #{stringified_deadline}, " \
              "the state will withdraw your payment as soon as they process your return."
            )
          end
        end

        context "when form is viewed on or after the payment deadline" do
          around do |example|
            Timecop.freeze(minute_before_tax_day_local + 1.minute) do
              example.run
            end
          end

          it "does not show the withdrawal date selector and explains when your payment will be withdrawn" do
            get :edit
            expect(response).to be_successful
            expect(response_html).not_to have_text(
              "When would you like the funds withdrawn from your account? (must be on or before #{stringified_deadline}):"
            )
            expect(response_html).to have_text(
              "Because you are submitting your return on or after #{stringified_deadline}, " \
              "the state will withdraw your payment as soon as they process your return."
            )
          end
        end
      end
    end
  end
end
