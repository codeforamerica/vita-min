class ScrapeVitaProvidersJob < ApplicationJob
  def perform
    results = ScrapeVitaProvidersService.new.import

    results.each do |provider_data|
      provider = VitaProvider.find_by(irs_id: provider_data[:irs_id]) || VitaProvider.new()
      provider.update(
        name: provider_data[:name],
        irs_id: provider_data[:irs_id],
        details: provider_data[:provider_details],
        dates: provider_data[:dates],
        hours: provider_data[:hours],
        languages: provider_data[:languages].join(","),
        appointment_info: provider_data[:appointment_info],
      )
      provider.set_coordinates(
        lat: provider_data[:lat_long].first,
        lon: provider_data[:lat_long][1]
      )
      provider.save
    end
  end
end