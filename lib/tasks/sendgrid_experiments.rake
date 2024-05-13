require 'sendgrid-ruby'
include SendGrid

namespace :sendgrid do
  desc 'Try a single email'
  # rake signup:delete_messaged ctc_2020_open_message
  task single_email: [:environment] do
    from = SendGrid::Email.new(email: 'mrotondo@codeforamerica.org')
    to = SendGrid::Email.new(email: 'mrotondo@codeforamerica.org')
    subject = 'Sending with SendGrid is Fun'
    content = SendGrid::Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
