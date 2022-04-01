require "rails_helper"

describe Hub::VerificationAttemptsController, type: :controller do
  let(:user) { create :user }

  describe '#index' do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when a user is logged in" do
      before do
        sign_in user
        3.times do
          create :verification_attempt, :pending
        end
        2.times do
          create :verification_attempt, :escalated
        end
      end

      it "renders okay" do
        get :index
        expect(response).to be_ok # 200: OK
        expect(response.status).to eq 200
      end

      it "defines @attempt_count as the number of pending VerificationAttempts in the database" do
        get :index

        expect(assigns(:attempt_count)).to eq 3 # VerificationAttempt.count
      end

      context "when a user is an admin" do
        let(:user) { create :admin_user }

        it "defines @attempt_count as the number of pending + escalated VerificationAttempts in the database" do
          get :index

          expect(assigns(:attempt_count)).to eq 5 # VerificationAttempt.count
        end
      end
    end
  end

  describe "#show" do
    let(:params) { { id: verification_attempt.id } }
    let(:verification_attempt) { create :verification_attempt }
    let(:fraud_double) { double(FraudIndicatorService) }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "when the user is logged in" do
      before do
        sign_in user

        allow(FraudIndicatorService).to receive(:new).and_return fraud_double
        allow(fraud_double).to receive(:hold_indicators).and_return ["duplicate_bank_account"]
      end

      context "rendering the page" do
        it "should render gracefully" do
          get :show, params: { id: verification_attempt.id }
          expect(response).to be_ok
        end

        context "when the client has not uploaded verification documents" do
          let(:verification_attempt) { VerificationAttempt.create(client: create(:client)) }

          it "should render gracefully" do
            get :show, params: { id: verification_attempt.id }
            expect(response).to be_ok
          end
        end
      end

      it "defines @verification_attempt as the VerificationAttempt object that matches the ID passed through the params" do
        get :show, params: { id: verification_attempt.id }

        expect(assigns(:verification_attempt)).to eq verification_attempt
      end

      it "defines @fraud_indicators as the result of fraud indicators from FraudIndicatorService" do
        get :show, params: { id: verification_attempt.id }

        expect(assigns(:form).fraud_indicators).to eq ["duplicate_bank_account"]
      end
    end
  end

  describe "#update" do
    let!(:verification_attempt) { create :verification_attempt, :pending }

    context "when a user is logged in" do
      before do
        sign_in user
      end

      let(:params) do
        {
            id: verification_attempt.id,
            state: "approved",
            hub_update_verification_attempt_form: {
                note: "some note"
          }
        }
      end

      context "when the form object is valid" do
        it "creates a new transition and stores the note, changes state then redirects to show page" do
          expect do
            post :update, params: params
          end.to change(verification_attempt.transitions, :count).by(1)
          expect(verification_attempt.last_transition.note).to be_present
          expect(verification_attempt.current_state).to eq "approved"
          expect(response).to redirect_to hub_verification_attempt_path(id: verification_attempt.id)
        end
      end

      context "when the form object is invalid" do
        before do
          allow_any_instance_of(Hub::UpdateVerificationAttemptForm).to receive(:valid?).and_return false
        end

        it "renders :show and does not persist changes" do
          expect do
            post :update, params: params
          end.to change(verification_attempt.transitions, :count).by(0)
          expect(response).to render_template :show
        end
      end
    end
  end
end
