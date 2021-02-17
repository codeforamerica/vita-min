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

  describe ".show?" do
    let(:stimulus_triage) { create(:stimulus_triage, filed_recently: filed_recently, need_to_correct: need_to_correct) }

    context "when client has filed recently" do
      let(:filed_recently) { "yes" }

      context "when the client does not need to correct their taxes" do
        let(:need_to_correct) { "no" }

        it "returns true" do
          expect(subject.class.show?(stimulus_triage)).to eq(true)
        end
      end

      context "when the client needs to correct their taxes" do
        let(:need_to_correct) { "yes" }

        it "returns false" do
          expect(subject.class.show?(stimulus_triage)).to eq(false)
        end
      end
    end

    context "when client has not filed recently" do
      let(:filed_recently) { "no" }

      context "when the client does not need to correct their taxes" do
        let(:need_to_correct) { "no" }

        it "returns false" do
          expect(subject.class.show?(stimulus_triage)).to eq(false)
        end
      end

      context "when the client needs to correct their taxes" do
        let(:need_to_correct) { "yes" }

        it "returns false" do
          expect(subject.class.show?(stimulus_triage)).to eq(false)
        end
      end
    end
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
        }.not_to change { stimulus_triage.reload.filed_prior_years }
      end
    end
  end
end
