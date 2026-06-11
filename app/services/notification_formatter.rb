class NotificationFormatter
  HEADER = "<!-- gyr-notification -->"

  def initialize(attrs)
    @subject = attrs[:subject].to_s
    @body = attrs[:body].to_s
    @recipient_name = attrs[:recipient_name].to_s
    @signature = attrs[:signature].to_s
  end

  def build
    template = compose_template
    MessageRenderer.render(template, locals: default_locals)
  end

  private

  def compose_template
    <<~ERB
      #{HEADER}
      <h1>#{@subject}</h1>
      <p>Hello #{@recipient_name},</p>
      <section class="body">
        #{@body}
      </section>
      <footer>#{@signature}</footer>
    ERB
  end

  def default_locals
    {
      app_name: "GetYourRefund",
      year: Time.current.year
    }
  end
end
