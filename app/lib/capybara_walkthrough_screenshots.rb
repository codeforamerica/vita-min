class CapybaraWalkthroughScreenshots
  def self.hook!(config)
    config.before(:each) do |example|
      CapybaraWalkthroughScreenshots.before(example)
    end

    config.after(:each) do
      CapybaraWalkthroughScreenshots.after
    end

    Capybara::Session.class_exec do
      capybara_visit = instance_method(:visit)

      define_method :visit do |*args|
        CapybaraWalkthroughScreenshots.append_screenshot
        capybara_visit.bind(self).call(*args)
        CapybaraWalkthroughScreenshots.append_screenshot
      end
    end

    Capybara::Node::Actions.module_exec do
      [:click_on, :click_button, :click_link].each do |capybara_method|
        orig = instance_method(capybara_method)
        define_method(capybara_method) do |*args|
          CapybaraWalkthroughScreenshots.append_screenshot
          orig.bind(self).call(*args)
          CapybaraWalkthroughScreenshots.append_screenshot
        end
      end
    end
  end

  private

  def self.before(example)
    # The screenshotter relies on the current test description being stored in a global (thread-local) variable,
    # from most specific to least specific.
    descriptions = [
      example.metadata[:description],
      example.metadata[:example_group][:description],
    ]

    # Add parent and grandparent (and grandgrandparent, etc.) name
    parent = example.metadata[:example_group][:parent_example_group]
    while parent && parent[:description]
      descriptions.push(parent[:description])
      parent = parent[:parent_example_group]
    end

    Thread.current[:_screenshot_file_path] = example.metadata[:file_path]

    # Add directory name to descriptions, omitting meaningless directory names
    example.metadata[:file_path].split("/").reject { |x| %w[. spec features].include?(x) }[0...-1].each do |dir_name|
      descriptions.push(dir_name)
    end
    Thread.current[:_screenshot_descriptions] = descriptions.map(&:titleize)
    Thread.current[:_screenshot_data] = []
  end

  def self.after
    append_screenshot # in case the page has changed

    # Convert characters into escaped versions, except / characters, which we treat specially
    dir_path = (%w[public walkthroughs] + Thread.current[:_screenshot_descriptions].reverse.map { |x| CGI.escape(x.gsub("/", " - ")) }).join("/")
    # Make a directory for this example, and save each screenshot
    FileUtils.mkdir_p(dir_path)
    Thread.current[:_screenshot_data].each_index do |i|
      # Save HTML content and current path
      File.open("#{dir_path}/#{i.to_s.rjust(5, '0')}.html", "w") do |file|
        file.write(Thread.current[:_screenshot_data][i][:body])
      end
      File.open("#{dir_path}/#{i.to_s.rjust(5, '0')}.path", "w") do |file|
        file.write(Thread.current[:_screenshot_data][i][:current_path])
      end
      File.open("#{dir_path}/#{i.to_s.rjust(5, '0')}.spec", "w") do |file|
        file.write(Thread.current[:_screenshot_file_path])
      end
    end
  end

  def self.append_screenshot
    # Save the screenshot if it is non-empty and different from the previous
    body = Capybara.page.body
    if Capybara.page.current_url.present? &&
       body.present? &&
       body != "<html><head></head><body></body></html>" &&
       Thread.current[:_screenshot_data][-1]&.dig(:body) != body
      parsed_uri = URI.parse(Capybara.page.current_url)
      current_path = parsed_uri.path
      current_path += "?" + parsed_uri.query if parsed_uri.query.present?
      Thread.current[:_screenshot_data].push(
        {
          body: body,
          current_path: current_path,
        }
      )
    end
  end
end
