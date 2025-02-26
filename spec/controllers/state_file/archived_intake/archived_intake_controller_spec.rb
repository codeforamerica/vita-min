require 'rails_helper'

describe StateFile::ArchivedIntakes::ArchivedIntakeController, type: :controller do
  let(:ip_address) { '192.168.0.1' }
  let(:email_address) { 'test@example.com' }
  let!(:archived_intake) {create :state_file_archived_intake, email_address: email_address}
  before do
    allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    session[:email_address] = email_address
  end

  describe '#current_request' do
    it 'finds the StateFileArchivedIntakeRequest by IP and email address' do
      expect(controller.current_archived_intake).to eq(archived_intake)
    end


    it 'matches email case insensitively' do
      session[:email_address] = 'TeSt@ExAmPlE.cOm'

      expect(controller.current_archived_intake).to eq(archived_intake)
    end

    it 'creates a new StateFileArchivedIntake when an email does not exist' do
      session[:email_address] = "new_email@domain.com"

      expect {
        @new_archived_intake = controller.current_archived_intake
      }.to change { StateFileArchivedIntake.count }.by(1)

      expect(@new_archived_intake.email_address).to eq("new_email@domain.com")
    end
  end

  describe '#create_state_file_access_log' do
    let(:event_type) { 'incorrect_ssn_challenge' }

    before do
      allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    end

    it 'creates a StateFileArchivedIntakeAccessLog with the correct attributes' do
      result = controller.create_state_file_access_log(event_type)

      expect(result).to be_a(StateFileArchivedIntakeAccessLog)
      expect(result.event_type).to eq event_type
      expect(result.state_file_archived_intake).to eq archived_intake
    end
  end

  describe '#check_feature_flag' do
    context 'when the feature flag is enabled' do
      before do
        allow(Flipper).to receive(:enabled?).with(:get_your_pdf).and_return(true)
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.check_feature_flag
      end
    end

    context 'when the feature flag is disabled' do
      before do
        allow(Flipper).to receive(:enabled?).with(:get_your_pdf).and_return(false)
      end

      it 'redirects to the root path' do
        expect(controller).to receive(:redirect_to).with(root_path)
        controller.check_feature_flag
      end
    end
  end

  describe '#is_intake_locked' do
    before do
      allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    end

    context 'when the request is nil' do
      before do
        allow(controller).to receive(:current_archived_intake).and_return(nil)
      end

      it 'redirects to verification error page' do
        expect(controller).to receive(:redirect_to).with(state_file_archived_intakes_verification_error_path)
        controller.is_intake_locked
      end
    end

    context 'when the request is locked' do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(true)
      end

      it 'redirects to verification error page' do
        expect(controller).to receive(:redirect_to).with(state_file_archived_intakes_verification_error_path)
        controller.is_intake_locked
      end
    end

    context 'when the archived intake is permanently locked' do
      before do
        allow(archived_intake).to receive(:permanently_locked_at).and_return(Time.current)
      end

      it 'redirects to verification error page' do
        expect(controller).to receive(:redirect_to).with(state_file_archived_intakes_verification_error_path)
        controller.is_intake_locked
      end
    end

    context 'when the request is valid and not locked' do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(false)
        allow(archived_intake).to receive(:permanently_locked_at).and_return(nil)
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.is_intake_locked
      end
    end
  end
end
