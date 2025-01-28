require "rails_helper"

describe StateFile::Questions::TaxesOwedController do

  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    context 'az' do
      let(:intake) { create :state_file_az_owed_intake}
      it 'succeeds' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).not_to have_text "Here is more information about tax due dates"
        expect(response_html).to have_text "Routing Number"
      end
    end

    context 'nj' do
      let(:intake) { create(:state_file_nj_intake)}
      it 'succeeds' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).to have_text "Here is more information about tax due dates"
        expect(response_html).to have_text "Routing Number"
      end

      context 'when taxpayer owes more than 400$ in taxes' do
        let(:intake) { create(:state_file_nj_intake, :df_data_taxes_owed)}
        it 'displays the underpayment notice' do
          get :edit
          expect(response).to be_successful
          expect(response_html).to have_text "This can happen for many reasons, but common ones are"
        end
      end
  
      context 'when taxpayer owes less than 400$ in taxes' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal)}
        it 'does not display the underpayment notice' do
          get :edit
          expect(response).to be_successful
          expect(response_html).not_to have_text "This can happen for many reasons, but common ones are"
        end
      end
    end

  end
end
