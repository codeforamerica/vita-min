class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  before_action :attach_logo

  def attach_logo
    data = File.read(Rails.root.join('public/images/logo.png'))
    attachments.inline['logo.png'] = data
  end
end
