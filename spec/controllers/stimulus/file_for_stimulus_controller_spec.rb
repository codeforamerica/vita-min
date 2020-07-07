require "rails_helper"

RSpec.describe Stimulus::FileForStimulusController do
  before do
    allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
  end

  describe '#show?' do
    context 'when needing to correct' do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: StimulusTriage.filed_recentlies['yes'], # TODO: investigate auto-pluralization
               need_to_correct: StimulusTriage.need_to_corrects['yes']) #  and here
      end

      it { expect(subject.class.show?(stimulus_triage)).to be_truthy }
    end

    context 'when needing to file' do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: StimulusTriage.filed_recentlies['no'], # TODO: investigate auto-pluralization
               need_to_file: StimulusTriage.need_to_files['yes']) #  and here
      end

      it { expect(subject.class.show?(stimulus_triage)).to be_truthy }
    end

    context 'when not needing to file or to correct' do
      let(:stimulus_triage) do
        create(:stimulus_triage,
               filed_recently: StimulusTriage.filed_recentlies['no'], # TODO: investigate auto-pluralization
               need_to_file: StimulusTriage.need_to_files['no']) #  and here
      end
      it { expect(subject.class.show?(stimulus_triage)).to be_falsey }
    end
  end
end
