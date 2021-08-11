class MixpanelJob < ApplicationJob
  def priority
    100 # lower numbers run first, see https://github.com/collectiveidea/delayed_job
  end

  def perform(distinct_id:, event_name:, data: {})
    MixpanelService.instance.run(distinct_id: distinct_id, event_name: event_name, data: data)
  end
end
