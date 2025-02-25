RSpec.shared_examples 'archived intake locked' do |action:, method: :get, params: {}|
  context 'when there is no archived intake' do
    before { allow(controller).to receive(:current_archived_intake).and_return(nil) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the archived intake is locked' do
    before { allow(controller.current_archived_intake).to receive(:access_locked?).and_return(true) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the archived intake is permanently locked' do
    before { allow(controller.current_archived_intake).to receive(:permanently_locked_at).and_return(Time.current) }

    it 'redirects to verification error page' do
      send(method, action, params: params)
      expect(response).to redirect_to(state_file_archived_intakes_verification_error_path)
    end
  end

  context 'when the archived intake is valid and not locked' do
    before do
      allow(controller.current_archived_intake).to receive(:access_locked?).and_return(false)
      allow(controller.current_archived_intake).to receive(:permanently_locked_at).and_return(nil)
    end

    it 'does not redirect' do
      send(method, action, params: params)
      expect(response).not_to be_redirect
    end
  end
end
