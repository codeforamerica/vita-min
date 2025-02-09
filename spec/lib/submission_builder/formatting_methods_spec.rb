require 'rails_helper'

describe SubmissionBuilder::FormattingMethods do
  let(:dummy_class) { Class.new() { extend SubmissionBuilder::FormattingMethods } }

  describe '#name_line_1_type' do
    subject(:formatted_name) { dummy_class.name_line_1_type(primary_first, primary_middle, primary_last, primary_suffix, spouse_first, spouse_middle, spouse_last) }

    let(:primary_first) { "Samantha" }
    let(:primary_middle) { nil }
    let(:primary_last) { "Seashells" }
    let(:primary_suffix) { nil }
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

      context 'with an accented middle initial' do
        let(:primary_middle) { "Ç" }
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

      context 'with a suffix' do
        let(:primary_suffix) { "Jr" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA<SEASHELLS<JR")
        end
      end

      context "when the name line is > 35" do
        context "due to a long first name" do
          let(:primary_first) { "Sssssaaaaaammmaaaannnthhhhaaaaaaaaaa"}
          it "truncates it correctly" do
            expect(formatted_name).to eq("S<S")
          end
        end

        context "due to a long last name" do
          let(:primary_last) { "Seeeeeeeeeeeeaaashhhhhhhhhhhhellllls"}
          let(:primary_middle) { "C" }
          it "truncates it correctly" do
            expect(formatted_name).to eq("SAMANTHA C<S")
          end
        end
      end
    end

    context 'when there is a spouse name' do
      let(:spouse_first) { "Cora" }
      let(:spouse_middle) { "Ç" }

      context "with a different last name" do
        let(:spouse_last) { "Coconut" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA<SEASHELLS<& CORA C COCONUT")
        end

        context 'with a primary suffix' do
          let(:primary_suffix) { "Jr" }
          it 'formats it correctly' do
            expect(formatted_name).to eq("SAMANTHA<SEASHELLS<JR & CORA C C")
          end
        end

        context "when the name line is > 35" do
          context "due to a long first name" do
            let(:spouse_first) { "Coooooooooooooooooooooooooooooooooora"}
            it "truncates it correctly" do
              expect(formatted_name).to eq("SAMANTHA<S<& C C")
            end
          end

          context "due to a long last name" do
            let(:spouse_last) { "Coooooooocoooooooooooonut" }
            it "truncates it correctly" do
              expect(formatted_name).to eq("SAMANTHA<SEASHELLS<& CORA C C")
            end
          end
        end
      end

      context "with the same last name" do
        let(:spouse_last) { "Seashells" }
        it 'formats it correctly' do
          expect(formatted_name).to eq("SAMANTHA & CORA C<SEASHELLS")
        end

        context 'with a primary suffix' do
          let(:primary_suffix) { "Jr" }
          it 'formats it correctly' do
            expect(formatted_name).to eq("SAMANTHA & CORA C<SEASHELLS<JR")
          end
        end

        context "when the name line is > 35" do
          let(:spouse_first) { "Coooooooooooooooooooooooooooooooooora"}
          it "truncates it correctly" do
            expect(formatted_name).to eq("SAMANTHA & C<S")
          end
        end
      end
    end
  end

  describe "#phone_type" do
    context "with a California phone number" do
      it "returns a 10-digit version without country code or formatting" do
        expect(dummy_class.phone_type("+14158161286")).to eq("4158161286")
      end
    end

    context "with a Puerto Rico phone number" do
      it "returns a 10-digit version without country code or formatting" do
        expect(dummy_class.phone_type("+17877640000")).to eq("7877640000")
      end
    end
  end

  describe "#sanitize_middle_initial" do
    let(:middle_initial) { nil }

    it "should return nil if middle_initial is not present" do
      expect(dummy_class.sanitize_middle_initial(middle_initial)).to be_nil
    end

    context "with bad middle initial" do
      let(:middle_initial) { "-" }

      it "should remove unaccepted character" do
        expect(dummy_class.sanitize_middle_initial(middle_initial)).to eq("")
      end
    end

    context "with preceding unaccepted characters before an acceptable character" do
      let(:middle_initial) { " -0 A B" }

      it "should remove unaccepted character and return the first acceptable character" do
        expect(dummy_class.sanitize_middle_initial(middle_initial)).to eq("A")
      end
    end
  end

  describe "#truncate" do
    include SubmissionBuilder::FormattingMethods
    it "doesn't affect valid strings" do
      expect(sanitize_for_xml("foo")).to eq "foo"
    end

    it "sanitizes internal and external whitespace" do
      expect(sanitize_for_xml(" \tf  \fo \vo  \t   bar\r\n ")).to eq "f o o bar"
    end

    it "strips whitespace resulting from truncation" do
      expect(sanitize_for_xml("Four Word Phrase", "Four Word ".length)).to eq "Four Word"
    end
  end
end
