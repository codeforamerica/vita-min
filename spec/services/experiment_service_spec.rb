require 'rspec'

describe ExperimentService do
  describe '#find_or_assign_treatment' do
    before do
      stub_const("ExperimentService::CONFIG", {
        'experiment_a' => {
          'treatment_x' => 1,
          'treatment_y' => 3
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
        ExperimentService.find_or_assign_treatment(experiment_id: 'experiment_a', record: DiyIntake.new)
      end
      expect(@treatments.length).to eq(1000)
      treatment_counts = @treatments.each_with_object(Hash.new(0)) { |treatment, hash| hash[treatment] += 1 }
      expect(treatment_counts['treatment_x'] / @treatments.length.to_f).to be_within(0.1).of(0.25)
      expect(treatment_counts['treatment_y'] / @treatments.length.to_f).to be_within(0.1).of(0.75)
    end
  end
end
