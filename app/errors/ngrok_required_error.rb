class NgrokRequiredError < StandardError
  def initialize(msg = "Start ngrok and add config.ngrok_url to your development.rb to use this feature in development.")
    super
  end
end