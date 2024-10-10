shared_examples :nc_state_id do
  describe 'simple validations' do
    context 'when no_id is set for id_type' do
      subject { described_class.new(nil, id_type: 'no_id') }

      it { should_not validate_presence_of :issue_date }
      it { should_not validate_presence_of :id_number }
      it { should_not validate_presence_of :state }
      it { should_not validate_presence_of :expiration_date }

      it { should_not validate_inclusion_of(:state).in_array(States.keys) }
    end

    context 'when non_expiring is set' do
      subject { described_class.new(nil, non_expiring: '1') }

      it { should_not validate_presence_of :expiration_date }
    end

    context 'when any other value is set for id_type' do
      subject { described_class.new(nil, id_type: 'driver_license') }

      it { should validate_presence_of :issue_date }
      it { should validate_presence_of :id_number }
      it { should validate_presence_of :state }
      it { should validate_presence_of :expiration_date }

      it { should validate_inclusion_of(:state).in_array(States.keys) }
    end
  end
end
