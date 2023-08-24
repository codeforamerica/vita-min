module StateHelper
  def state_name_from_abbreviation(key)
    States.name_for_key(key)
  end

  #can maybe remove this?
  def routing_fraction_to_percentage(fraction)
    "#{(fraction * 100).to_i}%"
  end
end