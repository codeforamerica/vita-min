require 'rails_helper'

describe ApplicationRecord do
  before do
    stub_const("ValidatingEnumRecord",
               Class.new(described_class) do
                 # Using arbitrary table and column name from the real schema
                 def self.table_name; "intakes"; end

                 enum_with_validation paid_self_employment_expenses: { unfilled: 0, yes: 1, no: 2 }, _prefix: :paid_self_employment_expenses
               end)
  end

  describe '#enum_with_validation' do
    context "when setting a valid value" do
      it "is valid and has the value" do
        record = ValidatingEnumRecord.new(paid_self_employment_expenses: 1)
        expect(record.paid_self_employment_expenses).to eq "yes"
        expect(record.errors).not_to include(:paid_self_employment_expenses)
      end

      it 'has the value suffix method' do
        record = ValidatingEnumRecord.new(paid_self_employment_expenses: 1)
        expect(record.paid_self_employment_expenses_yes?).to eq true
      end
    end

    context 'when setting an invalid value' do
      it 'marks the record as invalid' do
        record = ValidatingEnumRecord.new(paid_self_employment_expenses: 3)
        expect(record).not_to be_valid
        expect(record.errors).to include(:paid_self_employment_expenses)
      end
    end
  end
end
