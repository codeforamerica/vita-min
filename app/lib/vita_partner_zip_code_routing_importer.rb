require 'csv'

class VitaPartnerZipCodeRoutingImporter
  def create_vita_partner_zip_codes_from_csv(filename)
    # To use, run "VitaPartnerZipCodeRoutingImporter.new().create_vita_partner_zip_codes_from_csv('./wave_1_routing.csv')" in console

    data = CSV.read(filename, headers: true)

    data.map do |row|
      zip_codes = row[5]
      next unless zip_codes

      organization_name = row[0]
      vita_partner = VitaPartner.where(name: organization_name)&.first
      if vita_partner.nil?
        puts "Unable to find VitaPartner with name '#{organization_name}'"
        next
      end

      zip_codes.to_s.split(",").map do |zip_code|
        begin
          VitaPartnerZipCode.create!(zip_code: zip_code, vita_partner: vita_partner)
          puts "Created VitaPartnerZipCode with #{zip_code} for #{vita_partner&.name}"
        rescue => e
          puts "Unable to create VitaPartnerZipCode with #{zip_code} for #{vita_partner&.name} because: #{ e.message }"
        end
      end
    end
  end
end