module FeatureTestHelpers
  def changes_table_contents(selector)
    contents = {}

    all("#{selector} > tbody > tr").map do |tr|
      column, was, is = tr.find_xpath("td").map(&:visible_text)
      contents[column] = [was, is]
    end

    contents
  end
end
