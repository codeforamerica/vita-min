require "rails_helper"

describe Ctc::Questions::IncomeController, requires_default_vita_partners: true do
  context '#update' do
    let(:ip_address) { "127.0.0.1" }
    let(:had_reportable_income) { "no" }
    let(:params) do
      {
        ctc_income_form: {
          timezone: "America/Chicago",
          had_reportable_income: had_reportable_income,
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z",
        }
      }
    end

    before do
      request.remote_ip = ip_address
      cookies[:visitor_id] = "visitor-id"
      session[:source] = "some-source"
      session[:referrer] = "https://www.goggles.com/get-tax-refund"

      allow(MixpanelService).to receive(:send_event)
    end

    it "sends an event to mixpanel" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(hash_including(
        event_name: "question_answered",
        data: { had_reportable_income: "no" }
      ))
    end

    it "stores referrer, visitor_id, and referrer onto the intake" do
      post :update, params: params

      intake = Intake.last
      expect(intake.visitor_id).to eq "visitor-id"
      expect(intake.source).to eq "some-source"
      expect(intake.referrer).to eq "https://www.goggles.com/get-tax-refund"
    end

    it "updates client with intake security information" do
      expect {
        post :update, params: params
      }.to change(EfileSecurityInformation, :count).by 1

      expect(Client.last.intake.timezone).to eq "America/Chicago"
      efile_security = Client.last.efile_security_informations.last
      expect(efile_security.user_agent).to eq "GeckoFox"
      expect(efile_security.timezone).to eq "America/Chicago"
      expect(efile_security.ip_address).to eq ip_address
    end

    context "when answer is yes" do
      let(:had_reportable_income) { "yes" }
      it "redirects out of the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_use_gyr_path
      end
    end

    context "when the answer is no" do
      let(:had_reportable_income) { "no" }

      it "redirects to the next page in the flow" do
        post :update, params: params
        expect(response).to redirect_to questions_file_full_return_path
      end
    end

    context "efile security information fields are missing" do
      let(:params) do
        {
          ctc_income_form: {
          }
        }
      end

      it "does not create the client, shows a flash message" do
        expect {
          post :update, params: params
        }.not_to change(Client, :count)

        expect(flash[:alert]).to eq I18n.t("general.enable_javascript")
      end
    end

    context "capacity" do
      context "when there is no current capacity" do
        it "creates the intake as usual" do
          expect {
            post :update, params: params
          }.to change(Intake, :count)
        end
      end

      context "when CTC intakes are below capacity" do
        before do
          create(:ctc_intake_capacity, capacity: 5)
          create(:efile_submission)
        end

        it "creates the intake as usual" do
          expect {
            post :update, params: params
          }.to change(Intake, :count)
        end
      end

      context "when there are efile submissions in previous days but today does not exceed capacity" do
        before do
          create(:ctc_intake_capacity, capacity: 1)
          create(:efile_submission, created_at: 7.days.ago)
        end

        it "creates the intake as usual" do
          expect {
            post :update, params: params
          }.to change(Intake, :count)
        end
      end

      context "when we would exceed capacity with this intake" do
        before do
          create(:ctc_intake_capacity, capacity: 1)
          create(:efile_submission)
        end

        it "redirects to the at_capacity page and does not create an intake" do
          expect {
            post :update, params: params
          }.not_to change(Intake, :count)

          expect(response).to redirect_to questions_at_capacity_path
        end
      end
    end
  end
end
