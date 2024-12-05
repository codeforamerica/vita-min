require "rails_helper"

RSpec.describe StateFile::FaqController do
  render_views

  describe "#index" do
    let(:current_year) { Rails.configuration.state_file_start_of_open_intake.year }
    let(:tax_year) { current_year - 1 }
    before do
      allow(Rails.configuration).to receive(:statefile_current_tax_year).and_return(tax_year)
    end

    it "renders the page" do
      get :index, params: { us_state: "us" }

      expect(response).to be _ok
    end

    context "showing the right states" do
      let(:last_year_state_name) { "state that was open last year but not this year" }
      let(:continuing_state_name) { "state that was open last year and open this year" }
      let(:new_this_year_state_name) { "new state that will open this year" }
      let(:new_next_year_state_name) { "new state that will open next year" }
      before do
        allow(StateFile::StateInformationService).to receive(:filing_years).with(:last_year_state).and_return([tax_year - 1])
        allow(StateFile::StateInformationService).to receive(:filing_years).with(:continuing_state).and_return([tax_year + 1, tax_year, tax_year - 1])
        allow(StateFile::StateInformationService).to receive(:filing_years).with(:new_this_year_state).and_return([tax_year, tax_year + 1])
        allow(StateFile::StateInformationService).to receive(:filing_years).with(:new_next_year_state).and_return([tax_year + 1])

        allow(StateFile::StateInformationService).to receive(:state_code_to_name_map).and_return(
          {
            last_year_state: last_year_state_name,
            continuing_state: continuing_state_name,
            new_this_year_state: new_this_year_state_name,
            new_next_year_state: new_next_year_state_name,
          }
        )
      end

      context "when FYST has not opened yet for the year" do
        around do |example|
          Timecop.freeze(Rails.configuration.state_file_start_of_open_intake - 1.hour) do
            example.run
          end
        end

        context "in production" do
          before do
            allow(Rails).to receive(:env).and_return("production".inquiry)
          end

          it "shows only states that were open before and will reopen" do
            get :index, params: { us_state: "us" }

            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: last_year_state_name)
            expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: continuing_state_name)
            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: new_this_year_state_name)
            expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: new_next_year_state_name)
          end
        end

        context "in any other environment" do
          ["demo", "heroku", "development"].each do |environment|
            before do
              allow(Rails).to receive(:env).and_return(environment.inquiry)
            end

            it "shows states that will open this season" do
              get :index, params: { us_state: "us" }

              expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: last_year_state_name)
              expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: continuing_state_name)
              expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: new_this_year_state_name)
              expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: new_next_year_state_name)
            end
          end
        end
      end

      context "when FYST is either open or has closed for the year" do
        context "open" do
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes - 1.day) do
              example.run
            end
          end

          context "in any environment" do
            ["production", "demo", "heroku", "development"].each do |environment|
              before do
                allow(Rails).to receive(:env).and_return(environment.inquiry)
              end

              it "shows states that are currently open" do
                get :index, params: { us_state: "us" }

                expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: last_year_state_name)
                expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: continuing_state_name)
                expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: new_this_year_state_name)
                expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: new_next_year_state_name)
              end
            end
          end
        end

        context "after close" do
          around do |example|
            Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
              example.run
            end
          end

          context "in production" do
            before do
              allow(Rails).to receive(:env).and_return("production".inquiry)
            end

            it "shows only states that were open before and will reopen" do
              get :index, params: { us_state: "us" }

              expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: last_year_state_name)
              expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: continuing_state_name)
              expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: new_this_year_state_name)
              expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: new_next_year_state_name)
            end
          end

          context "in any other environment" do
            ["demo", "heroku", "development"].each do |environment|
              before do
                allow(Rails).to receive(:env).and_return(environment.inquiry)
              end

              it "shows states that will open next season" do
                get :index, params: { us_state: "us" }

                expect(response.body).not_to have_text I18n.t("state_file.faq.index.title", state: last_year_state_name)
                expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: continuing_state_name)
                expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: new_this_year_state_name)
                expect(response.body).to have_text I18n.t("state_file.faq.index.title", state: new_next_year_state_name)
              end
            end
          end
        end
      end
    end
  end
end