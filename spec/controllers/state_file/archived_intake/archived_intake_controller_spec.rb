require 'rails_helper'

describe StateFile::ArchivedIntakes::ArchivedIntakeController, type: :controller do
  let(:ip_address) { '192.168.0.1' }
  let(:email_address) { 'test@example.com' }
  let(:archived_intake) {create :state_file_archived_intake}
  let!(:request_instance) { create :state_file_archived_intake_request, ip_address: ip_address, email_address: email_address, state_file_archived_intake: archived_intake }
  before do
    allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    session[:email_address] = email_address
  end

  describe '#current_request' do
    it 'finds the StateFileArchivedIntakeRequest by IP and email address' do
      expect(controller.current_request).to eq(request_instance)
    end

    it 'returns nil if no request is found' do
      session[:email_address] = "non_existent_email@bad.com"
      expect(Rails.logger).to receive(:warn).with("StateFileArchivedIntakeRequest not found for IP: #{ip_address}, Email: non_existent_email@bad.com")
      expect(Sentry).to receive(:capture_message).with("StateFileArchivedIntakeRequest not found for IP: #{ip_address}, Email: non_existent_email@bad.com")

      expect(controller.current_request).to be_nil
    end

    it 'matches email case insensitively' do
      session[:email_address] = 'TeSt@ExAmPlE.cOm'

      expect(controller.current_request).to eq(request_instance)
    end
  end

  describe '#current_archived_intake' do
    it 'finds the StateFileArchivedIntakeRequest by IP and email address' do
      expect(controller.current_archived_intake).to eq(archived_intake)
    end

    context 'when a request does not have an intake' do
      let!(:request_instance) { create :state_file_archived_intake_request, ip_address: ip_address, email_address: email_address }
      it 'returns nil if no intake is found' do
        expect(controller.current_archived_intake).to be_nil
      end
    end
  end

  describe '#create_state_file_access_log' do
    let(:event_type) { 'incorrect_ssn_challenge' }

    before do
      allow(controller).to receive(:current_request).and_return(request_instance)
    end

    it 'creates a StateFileArchivedIntakeAccessLog with the correct attributes' do
      result = controller.create_state_file_access_log(event_type)

      expect(result).to be_a(StateFileArchivedIntakeAccessLog)
      expect(result.event_type).to eq event_type
      expect(result.state_file_archived_intake_request).to eq request_instance
    end

    context 'when current return is nil' do
      before do
        allow(controller).to receive(:current_request).and_return(nil)
      end
      it 'create a StateFileArchivedIntakeAccessLog' do
        result = controller.create_state_file_access_log(event_type)

        expect(result).to be_a(StateFileArchivedIntakeAccessLog)
        expect(result.event_type).to eq event_type
        expect(result.state_file_archived_intake_request).to eq nil
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
  end
end
