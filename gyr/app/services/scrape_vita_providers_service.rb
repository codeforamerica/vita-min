require 'open-uri'

class ScrapeVitaProvidersService
  def import
    base_url = "https://irs.treasury.gov/freetaxprep/jsp/vita.jsp?lat=37.7726402&lng=-122.40991539999999&radius=1000000&zip=94103"
    vita_sites = get_page_contents(base_url)

    (2..page_count).map do |page_number|
      url = base_url + "&page=#{page_number}"
      vita_sites += get_page_contents(url)
    end

    vita_sites
  end

  def get_page_contents(url)
    request_page(url)
    table_rows = @current_document.css('#locationDiv > table > tr')[1..-1]
    table_rows.map do |table_row|
      parse_table_row(table_row)
    end
  end

  private

  def request_page(url)
    html = URI.open(url).read
    @current_document = Nokogiri::HTML(html) do |config|
      config.noblanks
    end
  end

  def page_count
    @page_count ||= @current_document.at("span[text()='>']").parent.previous.previous.text.to_i
  end

  def parse_table_row(table_row)
    cells = table_row.css('> td')
    details_cell = cells.first
    detail_lines = details_cell.children.select{ |child| child.text.present? }
    link = detail_lines.last.attributes["href"].value
    link_params = CGI.parse(link.split("?")[1])
    {
        name: detail_lines[0].text.strip,
        provider_details: detail_lines[1...-1].map{|line| line.text.strip }.join("\n"),
        irs_id: link_params["id"].first,
        lat_long: [link_params["lat"].first, link_params["lng"].first],
        dates: text_or_nil(cells[2]),
        hours: format_hours(cells[3]),
        languages: cells[4].children.map { |child| child.text.strip }.select { |text| text.present? },
        appointment_info: text_or_nil(cells.last),
    }
  end

  def text_or_nil(element)
    text = element.text.strip
    text unless text.blank?
  end

  def format_hours(hours)
    return unless hours.text.strip.present?
    hours.css('tr').map { |row| "#{row.css('td').first.text} #{row.css('td')[1..-1].map(&:text).join()}" }.join("\n")
  end
end
