module WebpackerTestSupport
  TS_FILE = Rails.root.join('tmp', "webpacker-#{Rails.env}-timestamp")

  def self.compile_once
    return unless timestamp_outdated?

    if ENV['TEST_ENV_NUMBER'].to_i < 1
      public_output_path = Webpacker.config.public_output_path
      FileUtils.rm_r(public_output_path) if File.exist?(public_output_path)
      puts "Webpack is removed from output directory #{public_output_path}"
      puts 'Compiling, please wait'

      Webpacker.compile

      File.open(TS_FILE, 'w') { |f| f.write(Time.now.utc.to_i) }
      sleep(1)
    else
      loop do
        break unless timestamp_outdated?

        sleep 0.1
      end
    end
  end

  def self.timestamp_outdated?
    return true unless File.exist?(Webpacker.config.public_output_path)
    return true unless File.exist?(TS_FILE)

    current = current_bundle_timestamp(TS_FILE)

    return true unless current

    expected = Dir[Webpacker.config.source_path.join('**', '*')].map do |f|
      File.mtime(f).utc.to_i
    end.max

    current < expected
  end

  def self.current_bundle_timestamp(file)
    File.read(file).to_i
  rescue StandardError
    nil
  end
end

WebpackerTestSupport.compile_once

