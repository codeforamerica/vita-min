require 'rails_helper'

describe ExperimentService do
  describe '#find_or_assign_treatment' do
    let!(:experiment) { Experiment.create!(key: 'experiment_a', enabled: true) }

    before do
      stub_const("ExperimentService::CONFIG", {
        experiment.key => {
          name: "Experiment A",
          treatment_weights: {
            'treatment_x' => 1,
            'treatment_y' => 3
          }
        }
      })
    end

    it "assigns a treatment based on the weights defined for the experiment" do
      @treatments = []
      allow(ExperimentParticipant).to receive(:find_by).and_return(nil)
      allow(ExperimentParticipant).to receive(:create!) do |*args|
        treatment = args[0][:treatment]
        @treatments << treatment
        OpenStruct.new(treatment: treatment)
      end

      1000.times do
        ExperimentService.find_or_assign_treatment(key: experiment.key, record: DiyIntake.new)
      end
      expect(@treatments.length).to eq(1000)
      treatment_counts = @treatments.each_with_object(Hash.new(0)) { |treatment, hash| hash[treatment] += 1 }
      expect(treatment_counts['treatment_x'] / @treatments.length.to_f).to be_within(0.1).of(0.25)
      expect(treatment_counts['treatment_y'] / @treatments.length.to_f).to be_within(0.1).of(0.75)
    end

    context "a vita partner id is passed in" do
      let(:participating_vita_partner) { create :organization, experiments: [experiment] }
      let(:non_participating_vita_partner) { create :organization, experiments: [] }

      context "the vita partner is participating in the experiment" do
        let(:intake) { create :intake, vita_partner: participating_vita_partner }

        it "assigns a treatment" do
          expect {
            ExperimentService.find_or_assign_treatment(key: experiment.key, record: intake, vita_partner_id: participating_vita_partner.id)
          }.to change(ExperimentParticipant, :count).by 1
        end
      end

      context "the vita partner is not participating in the experiment" do
        let(:intake) { create :intake, vita_partner: non_participating_vita_partner }

        it "does not assign a treatment, returns nil" do
          expect {
            ExperimentService.find_or_assign_treatment(key: experiment.key, record: intake, vita_partner_id: non_participating_vita_partner.id)
          }.not_to change(ExperimentParticipant, :count)
        end
      end
    end
  end
end
