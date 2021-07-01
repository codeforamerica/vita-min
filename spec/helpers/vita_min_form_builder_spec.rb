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
        )

      expect(output).to be_html_safe

      expect(output).to match_html <<~HTML
        <div class="vita-min-searchbar form-group form-group--error" role="search">
          <div class="vita-min-searchbar__field">
            <label class="vita-min-searchbar__label sr-only" for="sample_query">Search for a book</label>
            <div>
              <div class="field_with_errors">
                <input class="vita-min-searchbar__input text-input" aria-describedby="sample_query__errors" type="text"
                       name="sample[query]" id="sample_query"/>
              </div>
            </div>
            <button class="vita-min-searchbar__button button button--primary" type="submit">
              <span class="vita-min-searchbar__submit-text hide-on-mobile">Search for a book</span>
              <i class="icon-navigate_next"></i>
            </button>
          </div>
          <span class="text--error" id="sample_query__errors"><i class="icon-warning"></i> Can't be blank. </span>
        </div>
      HTML
    end
  end

  describe "#vita_min_select" do
    it "can render a set of options with an h1 label" do
      class SampleForm < Cfa::Styleguide::FormExample
        attr_accessor :how_many
        validates_presence_of :how_many
      end
      sample = SampleForm.new
      sample.validate
      form = described_class.new("sample", sample, template, {})
      output = form.vita_min_select(
        :how_many,
        "This is for screen readers!",
        (0..10).map { |number| ["#{number} thing".pluralize(number), number] },
        help_text: "Choose how many",
        )
      expect(output).to be_html_safe
      expect(output).to match_html <<-HTML
        <div class="form-group form-group--error">
          <div class="field_with_errors">
            <label for="sample_how_many">
              <h1 class="form-question">This is for screen readers!</h1>
              <p class="text--help">Choose how many</p>
            </label>
          </div>
          <div class="select">
            <div class="field_with_errors">
              <select class="select__element" aria-describedby="sample_how_many__errors" name="sample[how_many]" id="sample_how_many">
                <option value="0">0 things</option>
                <option value="1">1 thing</option>
                <option value="2">2 things</option>
                <option value="3">3 things</option>
                <option value="4">4 things</option>
                <option value="5">5 things</option>
                <option value="6">6 things</option>
                <option value="7">7 things</option>
                <option value="8">8 things</option>
                <option value="9">9 things</option>
                <option value="10">10 things</option>
              </select>
            </div>
          </div>
          <span class="text--error" id="sample_how_many__errors"><i class="icon-warning"></i> Can't be blank. </span>
        </div>
      HTML
    end
  end

  describe "#vita_min_text_field" do
    it "adds help text and error ids to aria-labelledby" do
      class SampleForm < Cfa::Styleguide::FormExample
        attr_accessor :name
        validates_presence_of :name
      end

      form = SampleForm.new
      form.validate

      form_builder = described_class.new("form", form, template, {})
      output = form_builder.vita_min_text_field(
        :name,
        "How is name?",
        help_text: "Name is name",
        )
      expect(output).to be_html_safe
      expect(output).to match_html <<-HTML
        <div class="form-group form-group--error">
          <div class="field_with_errors">
            <label for="form_name">
              <h1 class="form-question">How is name?</h1>
              <p class="text--help">Name is name</p>
            </label>
          </div>
          <div class="field_with_errors">
            <input autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" class="text-input" aria-describedby="form_name__errors" id="form_name" type="text" name="form[name]" />
          </div>
          <span class="text--error" id="form_name__errors"><i class="icon-warning"></i> Can't be blank. </div>
        </div>
      HTML
    end
  end

  describe "#vita_min_date_text_fields" do
    it "renders three text fields for month, date and year" do
      class SampleForm < Cfa::Styleguide::FormExample
        attr_accessor :birth_date_day, :birth_date_month, :birth_date_year
        validates_presence_of :birth_date_day, :birth_date_month, :birth_date_year
      end

      form = SampleForm.new
      form.validate
      form_builder = described_class.new("form", form, template, {})
      output = form_builder.vita_min_date_text_fields(
        :birth_date,
        "Date of Birth (mm/dd/yyyy)",
        )
      expect(output).to be_html_safe
      doc = Nokogiri::HTML(output)
      expect(doc.css('input').map { |i| i.attribute('name').value }).to eq(["form[birth_date_day]", "form[birth_date_month]", "form[birth_date_year]"])
      expect(doc.css('input').map { |i| i.attribute('maxlength').value }).to eq(["2", "2", "4"])
    end
  end
end
