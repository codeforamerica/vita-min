namespace :fraud_indicators do
  desc 'Adds new fraud indicators to the db from the encrypted file'
  # rake fraud_indicators:add
  task add: :environment do
    JSON.parse(Rails.application.encrypted('app/models/fraud/indicators.json.enc', key_path: 'config/fraud_indicators.key', env_key: 'FRAUD_INDICATORS_KEY').read).each do |indicator_attributes|
      indicator = Fraud::Indicator.find_or_initialize_by(name: indicator_attributes['name'])

      next if indicator.persisted?

      indicator.assign_attributes(
        indicator_attributes.merge(
          'activated_at' => Time.zone.now,
          'query_model_name' => indicator_attributes['query_model_name']&.constantize
        )
      )
      indicator.save!
    end
  end
end