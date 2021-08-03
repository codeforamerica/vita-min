require 'rails_helper'

describe SubmissionBuilder::FormattingMethods do
  let(:dummy_class) { Class.new() { extend SubmissionBuilder::FormattingMethods } }

  describe '#name_line_1_type' do
    subject(:formatted_name) { dummy_class.name_line_1_type(primary_first, primary_middle, primary_last, spouse_first, spouse_middle, spouse_last) }

    let(:primary_first) { "Samantha" }
    let(:primary_middle) { nil }
    let(:primary_last) { "Seashells" }
    let(:spouse_first) { nil }
    let(:spouse_middle) { nil }
    let(:spouse_last) { nil }

    context 'when there is only a primary name' do
      context 'with a middle initial' do
        let(:primary_middle) { "C" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA C<SEASHELLS")
        end
      end

      context 'with an accent' do
        let(:primary_first) { "Sám" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAM<SEASHELLS")
        end
      end

      context 'with an apostrophe' do
        let(:primary_last) { "S/'shells" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA<SSHELLS")
        end
      end

      context 'with a hyphenated last name' do
        let(:primary_last) { "Sea-shells" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA<SEA-SHELLS")
        end
      end
    end

    context 'when there is a spouse name' do
      let(:spouse_first) { "Cora" }
      let(:spouse_middle) { "O" }

      context "with a different last name" do
        let(:spouse_last) { "Coconuts" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA<SEASHELLS<& CORA O COCONUTS")
        end
      end

      context "with the same last name" do
        let(:spouse_last) { "Seashells" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA & CORA O<SEASHELLS")
        end
      end
    end
  end
end