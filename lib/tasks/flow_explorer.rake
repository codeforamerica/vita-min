namespace :flow_explorer do
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
          acl: "public-read"
        )
      end
    end
  end
end
