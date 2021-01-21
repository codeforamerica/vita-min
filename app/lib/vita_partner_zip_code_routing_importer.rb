require 'csv'
require 'set'

class VitaPartnerZipCodeRoutingImporter
  def create_vita_partner_zip_codes_from_csv(filename)
    # to use, run "VitaPartnerZipCodeRoutingImporter.new().create_vita_partner_zip_codes_from_csv('./wave_1_routing.csv')" in console

    data = CSV.read(filename, headers: true)

    data.map do |row|
      # skip if no zip codes
      next unless row[5]

      vita_partner_name = row[0]
      vita_partner = VitaPartner.where(name: vita_partner_name)&.first
      if vita_partner.nil?
        puts "****Unable to find VitaPartner with name '#{vita_partner_name}'****"
        next
      end

      zip_codes = row[5].to_s.split(",").map { |s| s.to_i }
      zip_codes.map do |zip_code|
        # VitaPartnerZipCode.create!(zip_code: zip_code, vita_partner: vita_partner) if vita_partner
        puts "****Created VitaPartnerZipCode with #{zip_code} for #{vita_partner&.name}****"
      end
    end
  end
end