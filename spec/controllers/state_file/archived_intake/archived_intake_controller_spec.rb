require 'rails_helper'

describe StateFile::ArchivedIntakes::ArchivedIntakeController, type: :controller do
  let(:ip_address) { '192.168.0.1' }
  let(:email_address) { 'test@example.com' }
  let!(:request_instance) { create :state_file_archived_intake_request, ip_address: ip_address, email_address: email_address }
  before do
    allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    session[:email_address] = email_address
  end

  describe '#current_request' do
    it 'finds the StateFileArchivedIntakeRequest by IP and email address' do
      expect(controller.current_request).to eq(request_instance)
    end

    it 'returns nil if no request is found' do
      session[:email_address] = "non_existant_email@bad.com"

      expect(controller.current_request).to be_nil
    end
  end

  describe '#create_state_file_access_log' do
    let(:event_type) { 'incorrect_ssn_challenge' }
    let(:access_log_instance) { instance_double(StateFileArchivedIntakeAccessLog) }

    before do
      allow(controller).to receive(:current_request).and_return(request_instance)
    end

    it 'creates a StateFileArchivedIntakeAccessLog with the correct attributes' do
      result = controller.create_state_file_access_log(event_type)

      expect(result).to be_a(StateFileArchivedIntakeAccessLog)
      expect(result.event_type).to eq event_type
      expect(result.state_file_archived_intake_request).to eq request_instance
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
