class SessionToggle
  include ActiveModel::Model

  TOGGLE_TYPES = {
    'app_time' => 'datetime'
  }

  attr_reader :name
  attr_reader :session
  attr_reader :value

  def initialize(session, name)
    @session = session
    @name = name
    session_value = session[:session_toggles].try(:[], @name)
    if type == 'datetime' && session_value.present?
      @value = DateTime.parse(session_value)
    else
      @value = session_value
    end
  end

  def type
    TOGGLE_TYPES[@name]
  end

  def value=(new_value)
    if type == 'datetime'
      @value = Time.find_zone('America/Los_Angeles').parse(new_value)
    else
      @value = new_value
    end
  end

  def save
    session[:session_toggles] ||= {}
    session[:session_toggles][@name] = @value
  end

  def clear
    toggles = session[:session_toggles] || {}
    toggles.delete(@name)
    session[:session_toggles] = toggles
  end
end
