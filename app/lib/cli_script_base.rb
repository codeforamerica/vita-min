class CliScriptBase
  private

  def self.report_progress(text)
    puts text unless Rails.env.test?
  end
end