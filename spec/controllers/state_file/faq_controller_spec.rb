require "rails_helper"

RSpec.describe StateFile::FaqController do
  render_views

  describe "#index" do
    let(:current_year) { Rails.configuration.state_file_start_of_open_intake.year }
    before do
      allow(Rails.configuration).to receive(:statefile_current_tax_year).and_return(current_year - 1)
    end

    context "showing the right states" do
      context "when FYST has not opened yet for the year" do
        before do
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_1).and_return([current_year - 1, current_year - 2])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_2).and_return([current_year - 1])
          allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return({ state_abbrev_1: "state that was open last year", state_abbrev_2: "state that will be open this year but not yet" })
        end

        around do |example|
          Timecop.freeze(Rails.configuration.state_file_start_of_open_intake - 1.hour) do
            example.run
          end
        end

        it "shows states that were active the last time the app was open" do
          get :index, params: { us_state: "us" }

          expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "state that was open last year")
          expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "state that will be open this year but not yet")
        end
      end

      context "when FYST is either open or has closed for the year" do
        before do
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_1).and_return([current_year - 1, current_year - 2])
          allow(StateFile::StateInformationService).to receive(:filing_years).with(:state_abbrev_2).and_return([current_year - 2])
        end

        context "open" do
          before do
            allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return({ state_abbrev_1: "state that is open this year", state_abbrev_2: "state that was open last year but not this year" })
          end
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes - 1.day) do
              example.run
            end
          end

          it "shows states that are currently active" do
            get :index, params: { us_state: "us" }

            expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "state that is open this year")
            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "state that was open last year but not this year")
          end
        end

        context "after close" do
          before do
            allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return({ state_abbrev_1: "state that was open this year", state_abbrev_2: "state that was open last year but was not this year" })
          end
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
              example.run
            end
          end

          it "shows states that were active during the season" do
            get :index, params: { us_state: "us" }

            expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: "state that was open this year")
            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: "state that was open last year but was not this year")
          end
        end
      end
    end
  end
end