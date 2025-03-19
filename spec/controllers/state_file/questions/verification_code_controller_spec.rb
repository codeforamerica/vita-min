require 'rails_helper'

RSpec.describe StateFile::Questions::VerificationCodeController do
  before do
    sign_in intake
  end

  describe "#edit" do
    it_behaves_like :df_data_required, false, :az

    context "with an intake that prefers text message" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "text", phone_number: "+14153334444", visitor_id: "v1s1t1n9") }

      it "sets @contact_info to a pretty phone number" do
        get :edit

        expect(assigns(:contact_info)).to eq "(415) 333-4444"
      end

      it "enqueues a job to send verification code text message" do
        expect {
          get :edit
        }.to have_enqueued_job(RequestVerificationCodeTextMessageJob).with(
          phone_number: intake.phone_number,
          locale: I18n.locale,
          visitor_id: intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end
    end

    context "with an intake that prefers email" do
      let(:intake) { create(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9") }

      it "sets @contact_info to an email address" do
        get :edit

        expect(assigns(:contact_info)).to eq "someone@example.com"
      end

      it "enqueues a job to send verification code email" do
        expect {
          get :edit
        }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(
          email_address: intake.email_address,
          locale: I18n.locale,
          visitor_id: intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end
    end
  end

  describe "#update" do
    # making sure this one doesn't match
    let!(:existing_intake_with_df_data) { create(:state_file_az_intake, email_address: "shouldntmatchanything@please.org", raw_direct_file_data: "something") }
    context "with an intake matching an existing intake in the same state" do
      let!(:existing_intake) { create(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com") }
      let(:intake) do
        build(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9").tap do |intake|
          intake.raw_direct_file_data = nil
          intake.save!
        end
      end
      let(:token) { EmailAccessToken.generate!(email_address: "someone@example.com") }

      it "redirects to login" do
        post :update, params: { state_file_verification_code_form: { verification_code: token[0] }}
        login_location = StateFile::IntakeLoginsController.to_path_helper(
          action: :edit,
          id: VerificationCodeService.hash_verification_code_with_contact_info(
            "someone@example.com", token[0]
          )
        )
        expect(response).to redirect_to(login_location)
        expect(StateFileAzIntake.where(id: intake.id)).to be_empty
        expect(existing_intake.reload.unfinished_intake_ids).to include(intake.id.to_s)
      end
    end

    context "with an intake matching an existing intake in a different state" do
      let!(:existing_intake) { create(:state_file_id_intake, contact_preference: "email", email_address: "someone@example.com") }
      let(:intake) do
        build(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9").tap do |intake|
          intake.raw_direct_file_data = nil
          intake.save!
        end
      end
      let(:token) { EmailAccessToken.generate!(email_address: "someone@example.com") }

      it "redirects to login" do
        post :update, params: { state_file_verification_code_form: { verification_code: token[0] }}
        login_location = StateFile::IntakeLoginsController.to_path_helper(
          action: :edit,
          id: VerificationCodeService.hash_verification_code_with_contact_info(
            "someone@example.com", token[0]
          )
        )
        expect(response).to redirect_to(login_location)
        expect(StateFileAzIntake.where(id: intake.id)).to be_empty
        expect(existing_intake.reload.unfinished_intake_ids).to include(intake.id.to_s)
      end
    end

    context "without an intake matching an existing intake" do
      let(:intake) do
        build(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com", visitor_id: "v1s1t1n9").tap do |intake|
          intake.raw_direct_file_data = nil
          intake.save!
        end
      end
      let!(:existing_intake_no_df_data) do
        build(:state_file_az_intake, contact_preference: "email", email_address: "someone@example.com").tap do |intake|
          intake.raw_direct_file_data = nil
          intake.save!
        end
      end

      let(:token) { EmailAccessToken.generate!(email_address: "someone@example.com") }

      it "redirects to the next path" do
        post :update, params: { state_file_verification_code_form: { verification_code: token[0] }}
        expect(response).to redirect_to(questions_code_verified_path)
        expect(intake.reload).not_to be_destroyed
      end
    end
  end
end
