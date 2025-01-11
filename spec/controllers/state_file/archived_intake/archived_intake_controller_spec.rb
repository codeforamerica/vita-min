require 'rails_helper'

describe StateFile::ArchivedIntakes::ArchivedIntakeController, type: :controller do
  let(:ip_address) { '192.168.0.1' }
  let(:email_address) { 'test@example.com' }
  let(:request_instance) { instance_double(StateFileArchivedIntakeRequest) }

  before do
    allow(controller).to receive(:ip_for_irs).and_return(ip_address)
    allow(session).to receive(:[]).with(:email_address).and_return(email_address)
  end

  describe '#current_request' do
    it 'finds the StateFileArchivedIntakeRequest by IP and email address' do
      expect(StateFileArchivedIntakeRequest).to receive(:find_by).with(
        ip_address: ip_address,
        email_address: email_address
      ).and_return(request_instance)

      expect(controller.current_request).to eq(request_instance)
    end

    it 'returns nil if no request is found' do
      expect(StateFileArchivedIntakeRequest).to receive(:find_by).with(
        ip_address: ip_address,
        email_address: email_address
      ).and_return(nil)

      expect(controller.current_request).to be_nil
    end
  end

  describe '#create_state_file_access_log' do
    let(:event_type) { 'access_granted' }
    let(:access_log_instance) { instance_double(StateFileArchivedIntakeAccessLog) }

    before do
      allow(controller).to receive(:current_request).and_return(request_instance)
    end

    it 'creates a StateFileArchivedIntakeAccessLog with the correct attributes' do
      expect(StateFileArchivedIntakeAccessLog).to receive(:create!).with(
        event_type: event_type,
        state_file_archived_intake_request: request_instance
      ).and_return(access_log_instance)

      controller.create_state_file_access_log(event_type)
    end

    it 'raises an error if the log cannot be created' do
      allow(StateFileArchivedIntakeAccessLog).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        controller.create_state_file_access_log(event_type)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
