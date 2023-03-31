require "rails_helper"

RSpec.describe Diy::ContinueToFsaController do
  describe "#edit" do
    let(:diy_intake) { create(:diy_intake, :filled_out) }
    let(:experiments_enabled) { true }

    before do
      session[:diy_intake_id] = diy_intake&.id
    end

    context "with a diy intake id in the session" do
      it "returns 200 OK" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "without a valid diy intake id in the session" do
      let(:diy_intake) { nil }

      it "redirects to file yourself page" do
        get :edit

        expect(response).to redirect_to diy_file_yourself_path
      end
    end
  end

  describe "#click_fsa_link" do
    let(:diy_intake) { create(:diy_intake, :filled_out) }

    before do
      session[:diy_intake_id] = diy_intake&.id
    end

    xcontext "showing specific a TaxSlayer link" do
      context "experiment is not enabled" do
        let(:experiments_enabled) { false }
        before do
          allow(DiySupportExperimentService).to receive(:taxslayer_link).with(nil, nil).and_return("https://example.com/redirect_result")
        end

        it "sends a nil support_level treatment to DiySupportExperimentService" do
          get :edit

          expect(response).to redirect_to("https://example.com/redirect_result")
        end
      end

      context "client received a 1099" do
        let(:experiment) { Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT) }
        let(:taxslayer_links_1099) { [
          "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996",
          "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"
        ] }
        before do
          diy_intake.update(received_1099: "yes")
        end

        it "assigns client a group in the DIY_SUPPORT_LEVEL_EXPERIMENT and displays corresponding taxslayer link" do
          get :edit

          participant = ExperimentParticipant.find_by(experiment: experiment, record: diy_intake)
          expect(participant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)
          expect(assigns(:taxslayer_link)).to be_in(taxslayer_links_1099)
        end
      end

      context "client did not receive 1099 (presumed W-2)" do
        let(:experiment) { Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT) }
        let(:taxslayer_links_W2) { [
          "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434",
          "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"
        ] }
        before do
          diy_intake.update(received_1099: "no")
        end

        it "assigns client a group in the DIY_SUPPORT_LEVEL_EXPERIMENT and displays corresponding taxslayer link" do
          get :edit

          participant = ExperimentParticipant.find_by(experiment: experiment, record: diy_intake)
          expect(participant.treatment.to_sym).to be_in(experiment.treatment_weights.keys)
          expect(assigns(:taxslayer_link)).to be_in(taxslayer_links_W2)
        end
      end
    end

    context "with a diy intake id in the session" do
      context "when they are not part of the experiment" do
        before do
          allow(DiySupportExperimentService).to receive(:taxslayer_link).with("", false).and_return("https://example.com/redirect_result")
        end

        it "redirects to taxslayer" do
          get :click_fsa_link

          expect(response).to redirect_to "https://example.com/redirect_result"
        end
      end

      context "when they are part of the experiment" do
        before do
          ExperimentParticipant.create(
            experiment: Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT),
            record: diy_intake,
            treatment: support_level_treatment,
          )
          allow(DiySupportExperimentService).to receive(:taxslayer_link).with(support_level_treatment.to_s, received_1099 == "yes").and_return("https://example.com/redirect_result")
        end

        let(:received_1099) { false }

        context "when they are in the high treatment group of the experiment" do
          let(:support_level_treatment) { :high }

          it "sends them a support email" do
            expect do
              get :click_fsa_link
            end.to change(InternalEmail, :count).by(1)
                                                .and have_enqueued_job(SendInternalEmailJob)
            expect(response).to redirect_to("https://example.com/redirect_result")
          end
        end

        context "when they are in the low treatment group of the experiment" do
          let(:support_level_treatment) { :low }

          it "does not send them a support email" do
            expect do
              get :click_fsa_link
            end.not_to have_enqueued_job
            expect(response).to redirect_to("https://example.com/redirect_result")
          end
        end

        context "when the DIY client received a 1099" do
          let(:received_1099) { "yes" }
          let(:support_level_treatment) { nil }

          before do
            diy_intake.update(received_1099: "yes")
          end

          it "passes the value to DiySupportExperimentService" do
            get :click_fsa_link
            expect(response).to redirect_to("https://example.com/redirect_result")
          end
        end
      end

      context "without a valid diy intake id in the session" do
        let(:diy_intake) { nil }

        it "redirects to file yourself page" do
          get :edit

          expect(response).to redirect_to diy_file_yourself_path
        end
      end
    end
  end
end
