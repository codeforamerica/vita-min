require 'rails_helper'

describe FormattingHelper do
  describe '#format_text' do
    context "with replacement parameters to display" do
      let(:body) {
        <<~BODY
          <<Replacement.Param>> in a message
        BODY
      }
      let(:output) do
        <<~BODY
          <p><< Replacement.Param>> in a message
          </p>
        BODY
      end
      it "can gracefully display the replacement parameter" do
        expect(helper.format_text(body)).to eq output.chomp
      end
    end

    context "with open and close brackets that contain text that isn't parseable as a tag" do
      let(:body) do
        <<~BODY
          [[some emphasized text]] in a message
        BODY
      end

      let(:output) do
        <<~BODY
          <p>[[some emphasized text]] in a message
          </p>
        BODY
      end

      it "handles without failing and shows original text" do
        expect(helper.format_text(body)).to eq output.chomp
      end
    end

    context "with tags to interpret" do
      let(:body) {
        <<~BODY
          [[{\"id\":3,\"name\":\"Marty Melon\", \"value\":3,\"prefix\":\"@\"}]] in a message
        BODY
      }
      let(:output) do
        <<~BODY
          <p><span data-user-id='3' class='user-tag'>@Marty Melon</span> in a message
          </p>
        BODY
      end
      it "replaces the tag with a span including the name and prefix, with id in the data of the span" do
        expect(helper.format_text(body)).to eq output.chomp
      end
    end

    context "with multiple tags and replacement param to interpret" do
      let(:body) {
        <<~BODY
          [[{\"id\":3,\"name\":\"Marty Melon\", \"value\":3,\"prefix\":\"@\"}]] in a message

          with [[{\"id\":2,\"name\":\"Luna Lemon\", \"value\":2,\"prefix\":\"@\"}]] too

          <<Replace.Link>> <<Replace.Link>> [[Something Else]]
        BODY
      }

      let(:output) do
        <<~OUTPUT
          <p><span data-user-id='3' class='user-tag'>@Marty Melon</span> in a message</p>

          <p>with <span data-user-id='2' class='user-tag'>@Luna Lemon</span> too</p>

          <p><< Replace.Link>> << Replace.Link>> [[Something Else]]
          </p>
        OUTPUT
      end
      it "parses replacements and tags but leaves other contents within brackets alone" do
        expect(helper.format_text(body)).to eq output.chomp
      end
    end
  end
end