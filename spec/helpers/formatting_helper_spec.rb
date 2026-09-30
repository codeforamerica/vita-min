require "rails_helper"

describe FormattingHelper do
  describe "#note_body" do
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
        expect(helper.note_body(body)).to eq output.chomp
      end
    end

    context "with tags to interpret" do
      let(:body) {
        <<~BODY
          [[{\"id\":3,\"name_with_role\":\"Marty Melon (Admin)\", \"value\":3,\"prefix\":\"@\"}]] in a message
        BODY
      }
      let(:output) do
        <<~BODY
          <p><span class="user-tag">@Marty Melon (Admin)</span> in a message
          </p>
        BODY
      end
      it "replaces the tag with a span including the name and prefix, with id in the data of the span" do
        expect(helper.note_body(body)).to eq output.chomp
      end
    end

    context "with old tags to interpret" do
      # tags previously used name and not name_with_role in their json, this tests that the formatter is backwards compatible
      let(:body) {
        <<~BODY
          [[{\"id\":3,\"name\":\"Marty Melon\", \"value\":3,\"prefix\":\"@\"}]] in a message
        BODY
      }
      let(:output) do
        <<~BODY
          <p><span class="user-tag">@Marty Melon</span> in a message
          </p>
        BODY
      end
      it "replaces the tag with a span including the name and prefix, with id in the data of the span" do
        expect(helper.note_body(body)).to eq output.chomp
      end
    end

    context "with multiple tags and replacement param to interpret" do
      let(:body) {
        <<~BODY
          [[{\"id\":3,\"name_with_role\":\"Marty Melon (Admin)\", \"value\":3,\"prefix\":\"@\"}]] in a message

          with [[{\"id\":2,\"name_with_role\":\"Luna Lemon (Greeter)\", \"value\":2,\"prefix\":\"@\"}]] too
        BODY
      }

      let(:output) do
        <<~OUTPUT
          <p><span class="user-tag">@Marty Melon (Admin)</span> in a message</p>

          <p>with <span class="user-tag">@Luna Lemon (Greeter)</span> too</p>
        OUTPUT
      end
      it "parses replacements and tags but leaves other contents within brackets alone" do
        expect(helper.note_body(body.chomp)).to eq output.chomp
      end

      context "with unrelated HTML" do
        let(:body) {
          <<~BODY
          [[{\"id\":3,\"name_with_role\":\"Marty Melon (Admin)\", \"value\":3,\"prefix\":\"@\"}]] in a message

          with [[{\"id\":2,\"name_with_role\":\"Luna Lemon (Greeter)\", \"value\":2,\"prefix\":\"@\"}]] too

          <h1>harmless header tag is included</h1>

          <script>dangerous tag is definitely gone</script>
          BODY
        }

        let(:output) do
          <<~OUTPUT
          <p><span class="user-tag">@Marty Melon (Admin)</span> in a message</p>

          <p>with <span class="user-tag">@Luna Lemon (Greeter)</span> too</p>

          <p><h1>harmless header tag is included</h1></p>

          <p>dangerous tag is definitely gone</p>
          OUTPUT
        end

        it "keeps our HTML and sanitizes other HTML" do
          expect(helper.note_body(body.chomp)).to eq output.chomp
        end
      end
    end
  end

  describe "#message_body" do
    context "with a blank body" do
      it "shows a no content message" do
        expect(helper.message_body("")).to include "Message has no content."
      end
    end

    context "with plain text on multiple lines" do
      let(:body) { "Hello there\n\nHow are you?" }

      it "formats the text into paragraphs" do
        expect(helper.message_body(body)).to eq "<p>Hello there</p>\n\n<p>How are you?</p>"
      end
    end

    context "with HTML in the body" do
      let(:body) { "<li><script>alert(document.domain)</script>" }

      it "escapes the HTML so it is displayed as text" do
        expect(helper.message_body(body)).to eq "<p>&lt;li&gt;&lt;script&gt;alert(document.domain)&lt;/script&gt;</p>"
      end

      it "does not render any li or script elements" do
        html = Nokogiri::HTML.fragment(helper.message_body(body))
        expect(html.css("li, script")).to be_empty
        expect(html.text).to eq body
      end
    end
  end
end