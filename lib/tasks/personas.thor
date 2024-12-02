require_relative "../../config/environment"

class Personas < Thor
  desc "export", "Export the persona as either XML or JSON"

  method_option :state, aliases: '-s', desc: 'The relevant state', required: true
  method_option :xml, aliases: '-x', desc: "Retrieve XML persona", type: :boolean
  method_option :json, aliases: '-j', desc: "Retrieve JSON persona", type: :boolean
  method_option :debug, aliases: '-d', desc: 'Debug information', type: :boolean

  def export(id)
    # Make sure we have the attributes we need

    if options[:xml] && options[:json]
      say_error 'Please pass only one of --xml or --json', :red
      return 1
    end

    if !options[:xml] && !options[:json]
      say_error 'One of --xml or --json is required', :red
      return 1
    end

    intake_class = ::StateFile::StateInformationService.intake_class(options[:state])
    say_error "Intake class '#{intake_class.name}' selected", :cyan if options[:debug]

    intake = intake_class.find(id)

    if options[:xml]
      say_error "Outputtng xml", :cyan if options[:debug]

      say intake.raw_direct_file_data
      return
    end

    if options[:json]
      say_error "Outputting JSON", :cyan if options[:debug]
      say JSON.pretty_generate(
            intake.raw_direct_file_intake_data
          )
      return
    end
  end

  desc "import", "Imports a given persona with name. Accepts either XML or JSON"

  method_option :state, aliases: '-s', desc: 'The state in which to place the persona', required: true
  method_option :debug, aliases: '-d', desc: 'Debug information', type: :boolean

  def import(persona_name)
    # Can contain logging noise, so we must sanitize
    persona_contents = $stdin.readlines

    # Discard lines that don't begin with a bracket
    start_of_contents = persona_contents.index { |item| item.starts_with?('[', '<', '{') }

    persona_contents = persona_contents[start_of_contents..].join

    file_string = if persona_contents.first == '<'
                    say_error "Format detected as 'xml'", :cyan if options[:debug]
                    "spec/fixtures/state_file/fed_return_xmls/#{options[:state]}/#{persona_name}.xml"
                  else
                    say_error "Format detected as 'json'", :cyan if options[:debug]
                    "spec/fixtures/state_file/fed_return_jsons/#{options[:state]}/#{persona_name}.json"
                  end

    say_error "Creating file '#{file_string}'", :green

    File.write(file_string, persona_contents)
  end
end
