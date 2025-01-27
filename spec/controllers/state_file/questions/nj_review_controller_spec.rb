require "rails_helper"

RSpec.describe StateFile::Questions::NjReviewController do
  let(:intake) { create :state_file_nj_intake, :df_data_minimal }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context 'when no dependents and gross income at threshold' do
      it 'does not show the dependents without health insurance block' do
        allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_29).and_return 20_000
        get :edit       
        expect(response.body).not_to have_text "Dependents who DO NOT have health insurance"
      end
    end
  end
end