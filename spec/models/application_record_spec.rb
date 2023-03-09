require 'rails_helper'

describe ApplicationRecord do
  before do
    stub_const("Intake",
               Class.new(described_class) do
                 enum is_slick: { unfilled: 0, yes: 1, no: 2 }
                 validates_enum :is_slick
               end)
  end

  describe '#validates_enum' do
    context 'when setting an invalid value' do
      it 'marks the record as invalid' do
        expect(Intake.new(is_slick: 3)).not_to be_valid
      end
    end
  end
end
