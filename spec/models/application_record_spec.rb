require 'rails_helper'

describe ApplicationRecord do
  before do
    stub_const("Intake",
               Class.new(described_class) do
                 enum_with_validation is_slick: { unfilled: 0, yes: 1, no: 2 }
               end)
  end

  describe '#enum_with_validation' do
    context "when setting a valid value" do
      it "is valid and has the value" do
        record = Intake.new(is_slick: 1)
        expect(record).to be_valid
        expect(record.is_slick).to eq "yes"
      end
    end

    context 'when setting an invalid value' do
      it 'marks the record as invalid' do
        expect(Intake.new(is_slick: 3)).not_to be_valid
      end
    end
  end
end
