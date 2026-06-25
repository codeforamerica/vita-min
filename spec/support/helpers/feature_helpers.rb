module FeatureHelpers
  extend ActiveSupport::Concern

  class TriagePageDivergence < StandardError; end

  class TriageFeatureHelper
    attr_accessor :raise_instead
    def initialize(page, screenshot_method = nil, raise_instead = false)
      @seen_pages = []
      @page = page
      @screenshot_method = screenshot_method
      @raise_instead = raise_instead
    end

    def assert_page(title_key, &blk)
      first_line = I18n.t(title_key).split(/\n+/).first

      if @page.all('h2', text: first_line, wait: 0).length == 0
        return unless raise_instead
        raise Capybara::ElementNotFound
      end

      @seen_pages << @page.current_path

      @page.assert_selector("h2", text: first_line)
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
    defaults = {
      triage_income_level: "1_to_10000",
      triage_vita_income_ineligible: false,
      service_preference: "virtual_vita",
      triage_filing_status: "single",
      state_of_residence: "VA",
      had_qualifying_child: "yes"
    }

    options = defaults.merge(options)

    visit "/en/questions/eligibility-wages"

    # expect(page).to have_selector("h1", text: I18n.t('views.public_pages.home.header'))
    # click_on I18n.t('general.get_started')

    triage_feature_helper = TriageFeatureHelper.new(page, screenshot_method, true)
    page_change_block do
      triage_feature_helper.maybe_screenshot do
        # Personal Info
        expect(page).to have_selector("h2", text: I18n.t('questions.eligibility_wages.edit.title'))
        find("option[value='" + options[:triage_income_level] + "']").select_option
        check options[:triage_vita_income_ineligible] ? I18n.t('questions.eligibility_wages.edit.vita_income_ineligible.options.crypto') : I18n.t('questions.eligibility_wages.edit.vita_income_ineligible.options.none')
        click_on I18n.t('general.continue')
      end
    end

    page_change_block do
      triage_feature_helper.assert_page('questions.eligibility_state.edit.title') do
        choose "eligibility_state_form_service_preference_#{options[:service_preference]}"
        click_on I18n.t('general.continue')
      end
    end

    # uncomment when remove :show_simple_file flipper flag
    # page_change_block do
    #   triage_feature_helper.assert_page("questions.eligibility_household.edit.title") do
    #     choose(I18n.t("questions.eligibility_household.edit.household_status.#{options[:triage_filing_status]}"))
    #
    #     state_name = DiyStates.name_value_pairs.find { |_name, value| value == options[:state_of_residence] }&.first
    #
    #     select(state_name, from: I18n.t("questions.eligibility_household.edit.residence_state"))
    #
    #     expect(page).to have_select(I18n.t("questions.eligibility_household.edit.residence_state"), selected: state_name)
    #
    #     case options[:state_of_residence]
    #     when "CO"
    #       expect(page).to have_css("#qualifying-child-under-17", :visible)
    #       choose("eligibility_household_form_had_qualifying_child_under_17_#{options[:had_qualifying_child]}")
    #     when "NJ"
    #       expect(page).to have_css("#qualifying-child-under-6", :visible)
    #       choose("eligibility_household_form_had_qualifying_child_under_6_#{options[:had_qualifying_child]}")
    #     else
    #       expect(page).to have_css("#qualifying-child-under-17", visible: false)
    #       expect(page).to have_css("#qualifying-child-under-6", visible: false)
    #     end
    #
    #     click_on I18n.t("general.continue")
    #   end
    # end

    page_change_block do
      expect(page).not_to have_css("h1", text: I18n.t('questions.eligibility_state.edit.title'))
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
