module FeatureHelpers
  extend ActiveSupport::Concern

  class TriagePageDivergence < StandardError; end

  class TriageFeatureHelper
    def initialize(page, screenshot_method = nil)
      @seen_pages = []
      @page = page
      @screenshot_method = screenshot_method
    end

    def assert_page(title_key, &blk)
      first_line = I18n.t(title_key).split(/\n+/).first

      return unless @page.all('h1', text: first_line, wait: 0).length > 0

      @seen_pages << @page.current_path

      @page.assert_selector("h1", text: first_line)
      maybe_screenshot(&blk)
    end

    def maybe_screenshot
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

  def toggle_slider(selector)
    page.find(:checkbox, selector, visible: :all).ancestor('label').find('.slider').click
  end

  def answer_gyr_triage_questions(screenshot_method: nil, **options)
    if options[:choices] == :defaults
      options = {
        triage_income_level: "1_to_12500",
        triage_filing_status: "single",
        triage_filing_frequency: "not_filed",
        triage_vita_income_ineligible: false,
      }
    end

    visit "/en/questions/triage-personal-info"

    # expect(page).to have_selector("h1", text: I18n.t('views.public_pages.home.header'))
    # click_on I18n.t('general.get_started')

    triage_feature_helper = TriageFeatureHelper.new(page, screenshot_method)
    triage_feature_helper.maybe_screenshot do
      # Personal Info
      expect(page).to have_selector("h1", text: I18n.t('views.questions.personal_info.title'))
      fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Gary"
      fill_in I18n.t('views.questions.personal_info.phone_number'), with: "8286345533"
      fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "828-634-5533"
      fill_in I18n.t('views.questions.personal_info.zip_code'), with: "20121"
      click_on I18n.t('general.continue')
    end

    triage_feature_helper.assert_page('questions.triage_income_level.edit.title') do
      select I18n.t("questions.triage_income_level.edit.filing_status.options.#{options[:triage_filing_status]}")
      select I18n.t("questions.triage_income_level.edit.income_level.options.#{options[:triage_income_level]}")
      select I18n.t("questions.triage_income_level.edit.filing_frequency.options.#{options[:triage_filing_frequency]}")
      select options[:triage_vita_income_ineligible] ? I18n.t('general.affirmative') : I18n.t('general.negative'), from: I18n.t('questions.triage_income_level.edit.vita_income_ineligible.label')
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

  def table_contents(element_or_doc)
    rows = []
    if element_or_doc.class.name.start_with?('Nokogiri')
      nokotable = element_or_doc
    else
      result_table_text = element_or_doc["outerHTML"]
      if result_table_text.nil? && element_or_doc.native.instance_of?(Nokogiri::XML::Element)
        result_table_text = element_or_doc.native.to_html
      end
      nokotable = Nokogiri::HTML(result_table_text)
    end

    nokotable.css('tr').each do |row|
      cell_tag = row.css('th').any? ? 'th' : 'td'
      rows << (row.css(cell_tag).map(&:text).map(&:strip))
    end

    return [] if rows.size < 2

    rows[1..].map { |row| Hash[rows[0].zip(row)] }
  end

  def changes_table_contents(selector)
    contents = {}

    all("#{selector} > tbody > tr", visible: :any).map do |tr|
      column, was, is = tr.find_xpath("td").map(&:all_text)
      contents[column] = [was, is]
    end

    contents
  end

  def clear_cookies
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end

  def strip_inner_newlines(text)
    text.gsub(/\n/, '')
  end

  def strip_html_tags(text)
    ActionController::Base.helpers.strip_tags(text)
  end
  
  def fill_in_tagify(element, value)
    find(element).click
    find("#{element} .tagify__input").send_keys value
    find("#{element} .tagify__input").send_keys :enter
  end

  def select_cfa_date(base_name, date)
    select Date::MONTHNAMES[date.month], from: "#{base_name}_month"
    select date.day, from: "#{base_name}_day"
    select date.year, from: "#{base_name}_year"
  end
end
