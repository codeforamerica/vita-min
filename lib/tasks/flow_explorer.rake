namespace :flow_explorer do
  desc "Capture flow explorer screenshots by running specialized Capybara runs"
  task capture_screenshots: :environment do |_task|
    # We run specs in spec/features/ctc because the GYR specs sometimes fail.
    # TODO(someday): Remove "spec/features/ctc" from command lines below so we generate screenshots from
    # any spec marked flow_explorer_screenshot: true or flow_explorer_screenshot_i18n_friendly: true.
    [
      "rspec --tag flow_explorer_screenshot spec/features/ctc",
      "FLOW_EXPLORER_LOCALE=en rspec --tag flow_explorer_screenshot_i18n_friendly spec/features/ctc",
      "FLOW_EXPLORER_LOCALE=es rspec --tag flow_explorer_screenshot_i18n_friendly spec/features/ctc",
    ].each do |cmd|
      puts "RUNNING: #{cmd}"
      system(cmd)
    end
  end

  desc "Upload flow explorer screenshots to s3"
  task upload_screenshots: :environment do |_task|
    screenshots_path = Rails.root.join('public', 'assets', 'flow_screenshots')

    credentials = if ENV["AWS_ACCESS_KEY_ID"].present?
                    Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
                  else
                    Aws::Credentials.new(
                      Rails.application.credentials.dig(:aws, :access_key_id),
                      Rails.application.credentials.dig(:aws, :secret_access_key),
                    )
    end

    %w[en es].each do |locale|
      Dir[File.join(screenshots_path, locale, '*')].each do |screenshot_path|
        puts "Uploading #{screenshot_path}..."
        Aws::S3::Client.new(region: 'us-west-1', credentials: credentials).put_object(
          body: File.open(screenshot_path),
          bucket: "vita-min-flow-explorer-screenshots",
          key: File.join(locale.to_s, File.basename(screenshot_path)),
          acl: "public-read",
        )
      end
    end
  end
end
