require "rails_helper"

describe Hub::VerificationAttemptsController, type: :controller do
  let(:user) { create :user }

  describe '#index' do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when a user is logged in" do
      before do
        sign_in user
        3.times do
          create :verification_attempt
        end
      end

      it "renders okay" do
        get :index
        expect(response).to be_ok # 200: OK
        expect(response.status).to eq 200
      end

      it "defines @attempt_count as the number of VerificationAttempts in the database" do
        get :index

        expect(assigns(:attempt_count)).to eq 3 # VerificationAttempt.count
      end
    end
  end

  describe "#show" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    let(:verification_attempt) { create :verification_attempt }
    let(:fraud_double) { double(FraudIndicatorService) }

    context "when the user is logged in" do
      before do
        sign_in user

        allow(FraudIndicatorService).to receive(:new).and_return fraud_double
        allow(fraud_double).to receive(:hold_indicators).and_return ["duplicate_bank_account"]
      end

      it "should render gracefully" do
        get :show, params: { id: verification_attempt.id }
        expect(response).to be_ok
      end

      it "defines @verification_attempt as the VerificationAttempt object that matches the ID passed through the params" do
        get :show, params: { id: verification_attempt.id }

        expect(assigns(:verification_attempt)).to eq verification_attempt
      end

      it "defines @fraud_indicators as the result of fraud indicators from FraudIndicatorService" do
        get :show, params: { id: verification_attempt.id }

        expect(FraudIndicatorService).to have_received(:new).with(verification_attempt.client)
        expect(assigns(:fraud_indicators)).to eq ["duplicate_bank_account"]
      end
    end
  end
end
