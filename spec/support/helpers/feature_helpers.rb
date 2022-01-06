module FeatureHelpers
  extend ActiveSupport::Concern

  def answer_gyr_intake_questions(screenshot: false)
    def maybe_screenshot(screenshot)
      if screenshot
        screenshot_after do
          yield
        end
      else
        yield
      end
    end

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
      choose I18n.t('questions.triage_income_level.edit.levels.zero')
    end
    click_on I18n.t('general.continue')

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_start_ids.edit.title'))
    end
    click_on I18n.t('general.continue')

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_id_type.edit.title'))
    end
    choose I18n.t("questions.triage_id_type.edit.ssn_itin_type.have_paperwork")
    click_on I18n.t('general.continue')

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_doc_type.edit.title'))
    end
    choose strip_html_tags(I18n.t("questions.triage_doc_type.edit.doc_type.all_copies_html"))
    click_on I18n.t('general.continue')

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_backtaxes_years.edit.title'))
    end
    click_on I18n.t('general.continue')

    maybe_screenshot(screenshot) do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_assistance.edit.title'))
    end
    check I18n.t("general.none_of_the_above")
    click_on I18n.t('general.continue')
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
end
