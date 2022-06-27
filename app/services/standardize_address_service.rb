require 'net/http'
require 'uri'

# PLEASE do NOT use this service to standardize addresses in bulk (do NOT use in backfills)
# as that violates the terms of agreement with USPS and will result in access being revoked.
class StandardizeAddressService
  attr_accessor :timeout
  alias_method :timeout?, :timeout

  def initialize(intake, read_timeout: nil)
    @read_timeout = read_timeout
    @_street_address = [intake.street_address, intake.street_address2].map(&:presence).compact.join(" ")
    @_city = intake.city
    @_state = intake.state
    @_zip_code = intake.zip_code

    @result = build_standardized_address
    log_errors
  end

  # the USPS API sometimes responds with # to indicate apt number or with . included,
  # but the IRS does not allow those characters -- strip them out.
  def street_address
    @result[:street_address].gsub(/[#.]/, "").gsub(/(\s)+/, " ")
  end

  def city
    @result[:city]
  end

  def state
    @result[:state]
  end

  def zip_code
    @result[:zip_code]
  end

  def error_message
    return nil unless @result[:error_message]

    @result[:error_message].strip
  end

  def error_code
    return nil unless @result[:error_code]

    "USPS#{@result[:error_code].strip}"
  end

  def valid?
    return false if timeout?

    @result[:error_message].blank?
  end

  def has_verified_address?
    @result[:street_address].present? && @result[:city].present? && @result[:state].present? && @result[:zip_code].present?
  end

  private

  def log_errors
    if timeout?
      Rails.logger.error "Error from USPS Address API: Timed out."
    elsif !valid?
      Rails.logger.error "Error returned from USPS Address API: #{@result[:error_message]}"
    elsif @result[:zip_code].blank?
      Rails.logger.error "Error from USPS Address API: Response had no data."
      @result[:error_code] = "-MISSING-DATA"
      @result[:error_message] = "USPS API response had no data"
    end
  end

  def build_standardized_address
    usps_address_xml = get_usps_address_xml
    return {} unless usps_address_xml

    {
      street_address: usps_address_xml.xpath("//Address/Address2").text,
      city: usps_address_xml.xpath("//Address/City").text,
      state: usps_address_xml.xpath("//Address/State").text,
      zip_code: usps_address_xml.xpath("//Address/Zip5").text,
      error_message: usps_address_xml.xpath("//Error/Description").text,
      error_code: usps_address_xml.xpath("//Error/Number").text
    }
  end

  def get_usps_address_xml
    usps_user_id = EnvironmentCredentials.dig(:usps, :user_id)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.AddressValidateRequest(:USERID => usps_user_id) {
        xml.Revision 1
        xml.Address(:ID => 0) {
          xml.Address1
          xml.Address2 @_street_address
          xml.City @_city
          xml.State @_state
          xml.Zip5 @_zip_code
          xml.Zip4
        }
      }
    end

    request_address_xml = Nokogiri::XML(builder.to_xml)
    usps_request_address = "https://secure.shippingapis.com/ShippingAPI.dll?API=Verify&XML=#{ERB::Util.url_encode(request_address_xml)}"

    uri = URI(usps_request_address)
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: @read_timeout) { |http| http.request_get(uri) }

    response_xml = Nokogiri::XML(response.body)

    response_xml
  rescue Net::OpenTimeout
    @timeout = true
    nil
  end
end