require "rails_helper"

RSpec.describe Stimulus::VisitStimulusFaqController do
  let(:stimulus_triage) do
    create(:stimulus_triage,
           filed_recently: StimulusTriage.filed_recentlies['yes'],
           need_to_correct: StimulusTriage.need_to_corrects['no'],
           filed_prior_years: StimulusTriage.filed_prior_years['yes'])
  end

  before do
    allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
  end

  describe '#show?' do
    context 'when having filed in prior years' do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: StimulusTriage.filed_recentlies['yes'],
               need_to_correct: StimulusTriage.need_to_corrects['no'],
               filed_prior_years: StimulusTriage.filed_prior_years['yes'])
      end

      it { expect(subject.class.show?(stimulus_triage)).to be_truthy }
    end

    context 'when NOT having filed in prior years' do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: StimulusTriage.filed_recentlies['yes'],
               need_to_correct: StimulusTriage.need_to_corrects['no'],
               filed_prior_years: StimulusTriage.filed_prior_years['no'])
      end

      it { expect(subject.class.show?(stimulus_triage)).to be_falsey }
    end
  end

  describe '#edit' do
    before do
      session[:stimulus_triage_id] = "some_id"
      allow(subject).to receive(:clear_stimulus_triage_session).and_call_original
    end

    it 'clears the current_stimulus_triage out of the session after the page loads' do
      expect(subject).not_to have_received(:clear_stimulus_triage_session)
      get :edit

      expect(subject).to have_received(:clear_stimulus_triage_session)
      expect(session[:stimulus_triage_id]).to be_nil
    end
  end
end
