require 'airrecord'

namespace :airtable_vita_partner_sync do
  desc 'pulls VITA Partner data from airtable'
  task sync_vita_partners: [:environment] do
    base_id = "appdIlPE8OAKuVfJi"
    table_id = "tblE5d8IzeJEGAfIM"
    api_key = EnvironmentCredentials.dig("airtable_api_key")
    table = Airrecord.table(api_key, base_id, table_id)
    puts table.all.count
    puts "--"
    puts table.all.first.fields.keys
    puts "--"
    puts table.all.map { |org| "#{org['Organization Name']} - #{org['Language offerings']}" }

  end
end
