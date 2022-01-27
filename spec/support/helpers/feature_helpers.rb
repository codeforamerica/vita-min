module FeatureHelpers
  extend ActiveSupport::Concern

  class TriagePageDivergence < StandardError; end

  class TriageFeatureHelper
    def initialize(page, screenshot_method = nil)
      @seen_pages = []
      @page = page
      @screenshot_method = screenshot_method
    end

    def assert_page(title_key)
      first_line = I18n.t(title_key).split(/\n+/).first

      return unless @page.all('h1', text: first_line, wait: 0).length > 0

      @seen_pages << @page.current_path

      @page.assert_selector("h1", text: first_line)
      if @screenshot_method
        @screenshot_method.call { yield if block_given? }
      else
        yield if block_given?
      end
    end

    def seen_pages
      if @seen_pages.last != @page.current_path
        @seen_pages << @page.current_path
      end

      @seen_pages
    end
  end

  class TriageChoices
    def initialize(choices)
      @choices = choices
    end

    private

    def method_missing(symbol, *args)
      if @choices[symbol]
        @choices[symbol]
      else
        raise "Tried to get a value for #{symbol} but this test didn't provide one."
      end
    end
  end

  def answer_gyr_triage_questions(screenshot_method: nil, **options)
    if options[:choices] == :defaults
      options = {
        income_level: "hh_1_to_25100_html",
        id_type: "have_paperwork",
        doc_type: "all_copies_html",
        filed_past_years: [
          TaxReturn.current_tax_year - 3,
          TaxReturn.current_tax_year - 2,
          TaxReturn.current_tax_year - 1,
        ],
        assistance_options: ['in_person', 'phone_review_english', 'phone_review_non_english'],
        income_type_options: ['none_of_the_above']
      }
    end
    choices = TriageChoices.new(options)

    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    triage_feature_helper = TriageFeatureHelper.new(page, screenshot_method)
    triage_feature_helper.assert_page('questions.triage_income_level.edit.title') do
      choose strip_html_tags(I18n.t("questions.triage_income_level.edit.levels.#{choices.income_level}").split("\n").first)
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_start_ids.edit.title') do
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_id_type.edit.title') do
      choose I18n.t("questions.triage_id_type.edit.ssn_itin_type.#{choices.id_type}")
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_doc_type.edit.title') do
      choose strip_html_tags(I18n.t("questions.triage_doc_type.edit.doc_type.#{choices.doc_type}"))
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_backtaxes_years.edit.title') do
      choices.filed_past_years.each do |year|
        check year.to_s
      end
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_assistance.edit.title') do
      choices.assistance_options.each do |option|
        check option == 'none_of_the_above' ? I18n.t("general.none_of_the_above") : I18n.t("questions.triage_assistance.edit.assistance.#{option}")
      end
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_income_types.edit.title') do
      choices.income_type_options.each do |option|
        check option == 'none_of_the_above' ? I18n.t("general.none_of_the_above") : I18n.t("questions.triage_income_types.edit.income_types.#{option}")
      end
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.seen_pages
  end

  def screenshot_after
    yield

    if @metadata_screenshot && ENV["VITA_MIN_PERCY_ENABLED"].present?
      @screenshot_index = defined?(@screenshot_index) ? @screenshot_index + 1 : 1
      example_text, spec_path = inspect.match(/"(.*)" \(\.\/spec\/features\/(.*)_spec\.rb/)[1, 2]

      screenshot_name = "#{format('%02d', @screenshot_index)}|#{spec_path}|#{example_text.parameterize}|#{current_path.parameterize}"
      page.percy_snapshot(screenshot_name)
    end
  end

  def changes_table_contents(selector)
    contents = {}

    all("#{selector} > tbody > tr", visible: :any).map do |tr|
      column, was, is = tr.find_xpath("td").map(&:all_text)
      contents[column] = [was, is]
    end

    contents
  end

  def strip_inner_newlines(text)
    text.gsub(/\n/, '')
  end

  def strip_html_tags(text)
    ActionController::Base.helpers.strip_tags(text)
  end

  def current_tax_year
    TaxReturn.current_tax_year.to_i
  end

  def prior_tax_year
    current_tax_year - 1
  end

  def fill_in_tagify(element, value)
    find(element).click
    find("#{element} .tagify__input").send_keys value
    find("#{element} .tagify__input").send_keys :enter
  end
end
