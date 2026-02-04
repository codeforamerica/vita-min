namespace :flow_explorer do
  desc "Capture flow explorer screenshots by running specialized Capybara runs"
  task capture_screenshots: :environment do |_task|
    all_passed = true

    [
      "rspec --tag flow_explorer_screenshot",
    ].each do |cmd|
      puts "RUNNING: #{cmd}"
      result = system(cmd)
      all_passed = false unless result
    end

    abort "One or more tests failed!" unless all_passed
  end

  desc "Upload flow explorer screenshots to s3"
  task upload_screenshots: :environment do |_task|
    screenshots_path = Rails.root.join('public', 'assets', 'flow_screenshots')

    %w[en es].each do |locale|
      Dir[File.join(screenshots_path, locale, '*')].each do |screenshot_path|
        puts "Uploading #{screenshot_path}..."
        Aws::S3::Client.new(region: 'us-west-1').put_object(
          body: File.open(screenshot_path),
          bucket: "vita-min-flow-explorer-screenshots",
          key: File.join(locale.to_s, File.basename(screenshot_path)),
          acl: "public-read",
        )
      end
    end
  end
end
