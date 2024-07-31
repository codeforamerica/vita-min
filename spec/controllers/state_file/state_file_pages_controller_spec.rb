require "rails_helper"

describe StateFile::StateFilePagesController do
  render_views

  context "logged in pages" do
    let(:intake) { create :state_file_az_owed_intake }
    before do
      sign_in intake
    end

    describe '#fake_direct_file_transfer_page' do
      it 'succeeds' do
        get :fake_direct_file_transfer_page, params: { redirect: "test.com" }
        expect(response).to be_successful
      end
    end

    describe '#data_import_failed' do
      render_views
      it 'succeeds' do
        get :data_import_failed
        expect(response).to be_successful
      end
    end
  end

  describe '#about_page' do
    render_views
    it 'succeeds' do
      get :about_page
      expect(response).to be_successful
    end
  end

  describe '#privacy_policy' do
    render_views
    it 'succeeds' do
      get :privacy_policy
      expect(response).to be_successful
    end
  end

  describe '#coming_soon' do
    render_views
    it 'succeeds' do
      Timecop.freeze(Rails.configuration.state_file_start_of_open_intake + 1.minute) do
        get :coming_soon
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#clear_session' do
    render_views
    it 'succeeds' do
      get :clear_session
      expect(response).to redirect_to(root_path)
    end
  end

  describe '#login_options' do
    render_views
    it 'succeeds' do
      get :login_options
      expect(response).to be_successful
    end
  end
end
