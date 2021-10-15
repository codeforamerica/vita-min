# frozen_string_literal: true

require 'i18n/tasks'
require 'nokogiri'

RSpec.describe I18n do
  before(:all) do
    @i18n = I18n::Tasks::BaseTask.new
  end

  IGNORED_INCONSISTENT_HTML_KEYS = %w(
    hub.client_channel.please_reload_html
    hub.status_macros.file_accepted
    hub.status_macros.intake_greeter_info_requested
    hub.status_macros.intake_ready_for_call
    hub.status_macros.review_reviewing
    messages.ctc_getting_started.sms
    messages.efile.acceptance.email.body
    portal.tax_returns.authorize_signature_header.full_declaration.body_html
    verification_code_mailer.no_match.body_html
    views.consent_pages.global_carryforward.content_html
    views.ctc_pages.home.obtain.already_filed.body3_html
    views.ctc_pages.home.obtain.full_return.body1_html
    views.documents.employment.help_text_html
    views.public_pages.sms_terms.terms.rates_html
  )

  it "should have the same HTML tags in each locale" do
    inconsistent_html_keys = []

    # inspired by I18n::Tasks::Interpolations#inconsistent_interpolations
    @i18n.data[@i18n.base_locale].key_values.each do |key, value|
      Array(value).each_with_index do |scalar_value, index|
        next if !scalar_value.is_a?(String) || !scalar_value.include?('<')
        key_with_index = "#{key}#{value.is_a?(Array) ? "[#{index}]" : ''}"

        base_locale_tag_counts = Hash.new(0)
        Nokogiri::HTML(scalar_value).xpath("//*").each { |el| base_locale_tag_counts[el.name] += 1 }

        (@i18n.locales - [@i18n.base_locale]).each do |other_locale|
          node = @i18n.data[other_locale].first.children[key]
          if node&.value&.is_a?(Array)
            other_locale_value = node.value[index]
          else
            other_locale_value = node.value
          end

          tag_counts = Hash.new(0)
          Nokogiri::HTML(other_locale_value).xpath("//*").each { |el| tag_counts[el.name] += 1 }
          if base_locale_tag_counts != tag_counts
            inconsistent_html_keys << key_with_index
            if ENV['I18N_VERBOSE']
              puts <<~MESSAGE
                Inconsistent HTML in #{key_with_index}

                #{@i18n.base_locale}: #{base_locale_tag_counts.inspect}
                #{other_locale}: #{tag_counts.inspect}
                == #{@i18n.base_locale} ==
                #{scalar_value}
                == #{other_locale} ==
                #{other_locale_value}\n\n
              MESSAGE
            end
          end
        end
      end
    end

    inconsistent_html_keys -= IGNORED_INCONSISTENT_HTML_KEYS
    expect(inconsistent_html_keys).to be_empty, "The following I18n keys have inconsistent HTML across locales: #{inconsistent_html_keys.join(', ')}"
  end

  it "should be normalized" do
    # This is all in one test since the I18n task computes some data which can be re-used by different validations.
    expect(
      @i18n.non_normalized_paths
    ).to be_empty, "Translation files need to be normalized, run `i18n-tasks normalize` to fix them."
  end

  it "should have no unused keys" do
    expect(
      @i18n.unused_keys
    ).to be_empty, "#{@i18n.unused_keys.leaves.count} unused i18n keys, run `i18n-tasks health' to show them"
  end

  it "should have no missing keys" do
    expect(
      @i18n.missing_keys
    ).to be_empty, "#{@i18n.missing_keys.leaves.count} i18n keys are missing from a language, run `i18n-tasks health' to show them"
  end

  it "should have no inconsistent interpolations" do
    expect(
      @i18n.inconsistent_interpolations
    ).to be_empty, "#{@i18n.inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations, run `i18n-tasks health` to show them"
  end
end
