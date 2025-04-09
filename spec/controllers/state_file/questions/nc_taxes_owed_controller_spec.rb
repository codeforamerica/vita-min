require "rails_helper"

describe StateFile::Questions::NcTaxesOwedController do

  let(:intake) { create :state_file_nc_intake, :taxes_owed }

  before do
    sign_in intake
  end

  describe '#edit' do
    before do
      allow_any_instance_of(described_class).to receive(:app_time).and_return(app_time)
    end
    context 'before intake closes' do
      render_views
      let(:app_time) { DateTime.new(Time.now.year, 4, 12, 12, 0, 0) }
      it 'succeeds and has the date select div' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).to have_text "Routing Number"

        expect(response_html).to have_text "When would you like the funds withdrawn from your account?"
      end
    end

    context 'after intake closes' do
      render_views
      let(:app_time) { DateTime.new(Time.now.year, 4, 20, 12, 0, 0) }
      it 'succeeds and does not has the date select div' do
        get :edit
        expect(response).to be_successful
        expect(response_html).to have_text "You owe"
        expect(response_html).to have_text "Routing Number"
        expect(response_html).not_to have_text "When would you like the funds withdrawn from your account?"
      end
    end
  end
end
