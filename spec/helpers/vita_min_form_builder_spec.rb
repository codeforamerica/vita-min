require "rails_helper"

RSpec.describe VitaMinFormBuilder do
  let(:template) do
    template = OpenStruct.new(output_buffer: "")
    template.extend ActionView::Helpers::FormHelper
    template.extend ActionView::Helpers::DateHelper
    template.extend ActionView::Helpers::FormTagHelper
    template.extend ActionView::Helpers::FormOptionsHelper
  end

  describe "#vita_min_searchbar" do
    it "defaults to an accessible html output" do
      class SampleForm < Cfa::Styleguide::FormExample
        attr_accessor :query

        validates_presence_of :query
      end

      sample = SampleForm.new
      sample.validate
      form = described_class.new("sample", sample, template, {})
      output = form.vita_min_searchbar(
        :query,
        "Search for a book",
        options: { placeholder: "Enter book title" }
      )

      expect(output).to be_html_safe

      expect(output).to match_html <<~HTML
        <div class="vita-min-searchbar form-group form-group--error" role="search">
          <div class="vita-min-searchbar__field">
            <label class="vita-min-searchbar__label sr-only" for="sample_query">Search for a book</label>
            <div>
              <div class="field_with_errors">
                <input class="vita-min-searchbar__input text-input" placeholder="Enter book title" aria-describedby="sample_query__errors" type="text" name="sample[query]" id="sample_query" />
              </div>
            </div>
            <button class="vita-min-searchbar__button button button--primary" type="submit">
              <span class="vita-min-searchbar__submit-text hide-on-mobile">Search for a book</span>
              <i class="icon-navigate_next"></i>
            </button>
          </div>
          <span class="text--error" id="sample_query__errors"><i class="icon-warning"></i> can't be blank </span>
        </div>
      HTML
    end
  end
end