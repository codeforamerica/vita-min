require "rails_helper"

RSpec.describe Stimulus::FilingMightHelpController do
  let(:stimulus_triage) do
    create(:stimulus_triage,
           filed_recently: 'no',
           need_to_file: 'no')
  end

  before do
    allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
  end

  describe ".show?" do
    context "when client does not need to file" do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: 'no',
               need_to_file: 'no')
      end

      it "returns true" do
        expect(subject.class.show?(stimulus_triage)).to eq(true)
      end
    end

    context "when client did not file in prior years" do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: 'yes',
               need_to_correct: 'no',
               filed_prior_years: 'no')
      end

      it "returns true" do
        expect(subject.class.show?(stimulus_triage)).to eq(true)
      end
    end

    context "when client needs to file" do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: 'no',
               need_to_file: 'yes')
      end

      it "returns true" do
        expect(subject.class.show?(stimulus_triage)).to eq(false)
      end
    end

    context "when client did file in prior years" do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: 'yes',
               need_to_correct: 'no',
               filed_prior_years: 'yes')
      end

      it "returns true" do
        expect(subject.class.show?(stimulus_triage)).to eq(false)
      end
    end
  end

  describe '#update' do
    before do
      session[:stimulus_triage_id] = "something"
    end

    context 'when yes' do
      let(:params) do
        {
          'stimulus_filing_might_help_form': {
            chose_to_file: 'yes'
          }
        }
      end

      it "updates stimulus triage with filed_prior_years" do
        expect(stimulus_triage.chose_to_file).to eq('unfilled')
        post :update, params: params

        expect(stimulus_triage.chose_to_file).to eq('yes')
      end

      it 'redirects to the start of the intake flow' do
        post :update, params: params

        expect(response).to redirect_to(backtaxes_questions_path)
      end
    end

    context 'when no' do
      let(:params) do
        {
          'stimulus_filing_might_help_form': {
            chose_to_file: 'no'
          }
        }
      end

      it "updates stimulus triage with filed_prior_years" do
        expect(stimulus_triage.chose_to_file).to eq('unfilled')
        post :update, params: params

        expect(stimulus_triage.chose_to_file).to eq('no')
      end

      skip 'redirects to the beginning of EIP only intake' do
        post :update, params: params

        expect(response).to redirect_to(eip_overview_questions_path)
      end
    end
  end
end
