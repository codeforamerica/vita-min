require "rails_helper"

RSpec.describe Stimulus::FiledPriorYearsController do
  let(:stimulus_triage) do
    # w/o these settings, the controller should not fire
    create(:stimulus_triage,
           filed_recently: StimulusTriage.filed_recentlies['yes'], # TODO: investigate auto-pluralization
           need_to_correct: StimulusTriage.need_to_corrects['no']) #  and here
  end

  before do
    allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
  end

  describe '#update' do
    context 'when yes' do
      let(:params) do
        {
          'stimulus_filed_prior_years_form': {
            filed_prior_years: 'yes'
          }
        }
      end

      it "updates stimulus triage with filed_prior_years" do
        expect(stimulus_triage.filed_prior_years).to eq('unfilled')
        post :update, params: params

        expect(stimulus_triage.filed_prior_years).to eq('yes')
      end
    end

    context 'when no' do
      let(:params) do
        {
          'stimulus_filed_prior_years_form': {
            filed_prior_years: 'no'
          }
        }
      end

      it "updates stimulus triage with filed_prior_years" do
        expect(stimulus_triage.filed_prior_years).to eq('unfilled')
        post :update, params: params

        expect(stimulus_triage.filed_prior_years).to eq('no')
      end
    end

    context 'with garbage parameters' do
      let(:params) do
        {
          'stimulus_filed_prior_years_form': {
            filed_prior_years: 'garbage'
          }
        }
      end

      it "doesn't change the model's filed_prior_years" do
        expect(stimulus_triage.filed_prior_years).to eq('unfilled')
        expect {
          post :update, params: params
        }.to raise_error(ArgumentError)
      end
    end
  end
end
