namespace :fraud_indicators do
  desc 'Updates fraud indicators in the db to match the encrypted file'
  # rake fraud_indicators:update
  task update: [:environment] do
    update_fraud_indicators
  end

  # rake fraud_indicators:preview_updates
  task preview_updates: [:environment] do
    update_fraud_indicators(preview: true)
  end

  def update_fraud_indicators(preview: false)
    JSON.parse(Rails.application.encrypted('app/models/fraud/indicators.json.enc', key_path: 'config/fraud_indicators.key', env_key: 'FRAUD_INDICATORS_KEY').read).each do |indicator_attributes|
      indicator = Fraud::Indicator.find_or_initialize_by(name: indicator_attributes['name'])

      indicator_attributes['activated_at'] = Time.zone.now unless indicator.persisted?
      indicator_attributes['query_model_name'] = indicator_attributes['query_model_name']&.constantize
      indicator.assign_attributes(indicator_attributes)
      if preview
        if !indicator.persisted?
          Rails.logger.info "adds: #{indicator.attributes.except("id", "activated_at", "created_at", "updated_at")}"
        elsif indicator.changed?
          Rails.logger.info "updates: #{indicator.changes}"
        end
      else
        indicator.save!
      end
    end
  end
end