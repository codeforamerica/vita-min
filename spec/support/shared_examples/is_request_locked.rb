RSpec.shared_examples 'archived intake request locked' do |action:, method: :get, params: {}|
  context 'when the request is nil' do
    before { allow(controller).to receive(:current_request).and_return(nil) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the request is locked' do
    before { allow(current_request).to receive(:access_locked?).and_return(true) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the archived intake is permanently locked' do
    before { allow(archived_intake).to receive(:permanently_locked_at).and_return(Time.current) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the request is valid and not locked' do
    before do
      allow(current_request).to receive(:access_locked?).and_return(false)
      allow(archived_intake).to receive(:permanently_locked_at).and_return(nil)
    end

    it 'does not redirect' do
      send(method, action, params: params)
      expect(response).not_to be_redirect
    end
  end
end
