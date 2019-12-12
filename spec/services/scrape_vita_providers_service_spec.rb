require "rails_helper"

describe ScrapeVitaProvidersService do
  let(:service) { ScrapeVitaProvidersService.new }
  let(:base_url) { "https://irs.treasury.gov/freetaxprep/jsp/vita.jsp?zip=94103&lat=37.7726402&lng=-122.40991539999999&radius=1000000" }
  let(:html_file) { file_fixture("vita_providers_page_1.html").read }

  before do
    stub_request(:get, /freetaxprep/).to_return(status: 200, body: html_file, headers: {})
  end

  it "requests all the correct pages" do
    service.import

    expect(WebMock).to have_requested(:get, base_url)
    (1..21).each do |page_number|
      page_url = base_url + "&page=#{page_number}"
      expect(WebMock).to have_requested(:get, page_url)
    end
  end

  describe "#get_page_contents" do
    it "returns structured data" do
      results = service.get_page_contents(base_url)

      expect(results.length).to eq 10
      first_result = results.first
      expect(first_result[:provider_details]).to eq <<~DETAILS.strip
        777 Stockton Street
        #104
        San Francisco, CA 94108
        415-421-2111
        Volunteer Prepared Taxes
      DETAILS
      expect(first_result[:name]).to eq("Chinese Newcomers Service Ctr")
      expect(first_result[:irs_id]).to eq("4206")
      expect(first_result[:lat_long]).to eq(["37.792618", "-122.407631"])
      expect(first_result[:dates]).to eq("26 JAN 2019 - 12 OCT 2019")
      expect(first_result[:hours]).to be_nil
      expect(first_result[:languages]).to eq(["Chinese", "Cantonese", "Mandarin", "English", "Vietnamese"])
      expect(first_result[:appointment_info]).to eq("Required")
    end
  end

  context "when a provider has a whole nested table dedicated to hours" do
    let(:html_file) { file_fixture("provider_row_with_hour_table.html").read }

    it "parses the separate fields correctly" do
      results = service.get_page_contents(base_url)

      expect(results.length).to eq 1
      first_result = results.first
      expect(first_result[:provider_details]).to eq <<~DETAILS.strip
        6500 Rookin
        Bldg C
        Houston, TX 77074
        713-957-4357
        Volunteer Prepared Taxes
      DETAILS
      expect(first_result[:name]).to eq("BakerRipley Year Round Center")
      expect(first_result[:irs_id]).to eq("10202")
      expect(first_result[:lat_long]).to eq(["29.710592", "-95.496816"])
      expect(first_result[:dates]).to eq("06 MAY 2019 - 15 NOV 2019")
      expect(first_result[:languages]).to eq(["Spanish", "English"])
      expect(first_result[:appointment_info]).to eq("Not Required")
      expect(first_result[:hours]).to eq <<~HOURS.strip
        MON 10:00AM-5:00PM
        TUE 10:00AM-5:00PM
        WED 10:00AM-5:00PM
        THU 10:00AM-5:00PM
        FRI 12:00PM-4:00PM
      HOURS
    end
  end
end
