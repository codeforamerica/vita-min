require "rails_helper"

RSpec.describe StateFile::FaqController do
  render_views

  describe "#index" do
    let(:current_year) { Rails.configuration.state_file_start_of_open_intake.year }
    before do
      allow(Rails.configuration).to receive(:statefile_current_tax_year).and_return(current_year - 1)
    end

    it "renders the page" do
      get :index, params: { us_state: "us" }

      expect(response).to be_ok
    end

    context "showing the right states" do
      shared_examples :showing_only_states_that_were_open_and_will_reopen do
        it "shows the right states" do
          get :index, params: { us_state: "us" }

          expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "state that was open last season and will reopen next season")
          expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "new state that will be open this season but not yet")
          expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "state that was open last season but will not reopen this season")
        end
      end

      before do
        allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return(
          {
            state_abbrev_1: "state that was open last season and will reopen next season",
            state_abbrev_2: "new state that will be open this season but not yet",
            state_abbrev_3: "state that was open last season but will not reopen this season"
          }
        )
      end

      context "when FYST has not opened yet for the year" do
        before do
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_1).and_return([current_year - 1, current_year - 2])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_2).and_return([current_year - 1])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_3).and_return([current_year - 2])
        end

        around do |example|
          Timecop.freeze(Rails.configuration.state_file_start_of_open_intake - 1.hour) do
            example.run
          end
        end

        it_behaves_like :showing_only_states_that_were_open_and_will_reopen
      end

      context "when FYST is either open or has closed for the year" do
        before do
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_1).and_return([current_year, current_year - 1, current_year - 2])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_2).and_return([current_year - 1])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_3).and_return([current_year - 2])
        end

        context "open" do
          before do
            allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return(
              {
                state_abbrev_1: "state that is open this season",
                state_abbrev_2: "new state that just opened this season",
                state_abbrev_3: "state that was open last season but not this season"
              }
            )
          end
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes - 1.day) do
              example.run
            end
          end

          it "shows states that are currently open" do
            get :index, params: { us_state: "us" }

            expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "state that is open this season")
            expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "new state that just opened this season")
            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "state that was open last season but not this season")
          end
        end

        context "after close" do
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
              example.run
            end
          end

          it_behaves_like :showing_only_states_that_were_open_and_will_reopen
        end
      end
    end
  end
end