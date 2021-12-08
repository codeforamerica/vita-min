module FeatureTestHelpers
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
end
