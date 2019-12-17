RSpec::Matchers.define :match_html do |expected|
  def clean_html(string)
    string = string.squish.gsub(/>(\s)+</, "><")
    Nokogiri::HTML.fragment(string).to_xhtml(
      indent: 2, save_options: Nokogiri::XML::Node::SaveOptions::AS_HTML,
      )
  end

  match do |actual|
    @actual = clean_html(actual)
    @expected = clean_html(expected)
    values_match? @expected, @actual
  end

  failure_message do |_actual|
    diff = RSpec::Support::Differ.new.diff_as_string(@actual, @expected)
    "EXPECTED:\n#{@actual}\n\nTO EQUAL:\n#{@expected}\n\nDIFF:#{diff}"
  end
end