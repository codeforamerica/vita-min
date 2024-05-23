require 'sendgrid-ruby'
require 'ruby-handlebars'

include SendGrid

namespace :sendgrid do
  task single_email: [:environment] do
    from = SendGrid::Email.new(email: 'mrotondo@codeforamerica.org')
    to = SendGrid::Email.new(email: 'mrotondo@codeforamerica.org')
    subject = 'Sending with SendGrid is Fun'
    content = SendGrid::Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: EnvironmentCredentials.dig(:sendgrid_api_key))
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  task template_email: [:environment] do
    template_fields = {
      "name": "Mike from Rake",
      "tax_due_date": "April 15",
      "tax_submission_site_url": "https://fileyourstatetaxes.org",
      "tax_submission_site_display_name": "fileyourstatetaxes.org",
      "url_parameter": "fyst"
    }

    mail = SendGrid::Mail.new
    mail.from = SendGrid::Email.new(email: 'mrotondo@codeforamerica.org')
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: 'mrotondo@codeforamerica.org'))
    personalization.add_dynamic_template_data(template_fields)
    mail.add_personalization(personalization)
    mail.template_id = 'd-069315ea3d33402280a088d3534c8a9b'

    sg = SendGrid::API.new(api_key: EnvironmentCredentials.dig(:sendgrid_api_key))
    begin
      response = sg.client.mail._("send").post(request_body: mail.to_json)
    rescue Exception => e
      puts e.message
    end
    puts response.status_code
    puts response.body
    puts response.headers

  end

  task template_preview: [:environment] do
    template_fields = {
      "english": false,
      "spanish": true,
      "name": "Mike",
      "client_id": "163",
      "english_tax_due_date": "April 15",
      "spanish_tax_due_date": "15 abril",
      "tax_submission_site_url": "https://fileyourstatetaxes.org",
      "tax_submission_site_display_name": "fileyourstatetaxes.org",
      "url_parameter": "fyst"
    }
    sg = SendGrid::API.new(api_key: EnvironmentCredentials.dig(:sendgrid_api_key))
    template_id = "d-069315ea3d33402280a088d3534c8a9b"
    response = sg.client.templates._(template_id).get()
    puts response.status_code
    puts response.headers
    version = response.parsed_body[:versions].select { |version| version[:active] == 1 }[0]

    hbs = Handlebars::Handlebars.new
    f = File::open("template_preview.html", "w")
    f.write hbs.compile(version[:html_content]).call(template_fields)
    f.close
  end
end
