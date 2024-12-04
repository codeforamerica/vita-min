require_relative "../../config/environment"

class Personas < Thor
  desc "export INTAKE_ID", "Export the persona as either XML or JSON"

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

    intake = find_intake(id)

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

  desc "import PERSONA_SLUG", "Imports a given persona with name. Accepts either XML or JSON"

  method_option :state, aliases: '-s', desc: 'The state in which to place the persona', required: true
  method_option :debug, aliases: '-d', desc: 'Debug information', type: :boolean

  def import(persona_name)
    persona_name = persona_name.downcase
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

  desc "export_federal_submission_id INTAKE_ID", "Exports a submission id to be imported by import_federal_submission_id"
  method_option :state, aliases: '-s', desc: 'The relevant state', required: true

  def export_federal_submission_id(id)
    intake = find_intake(id)

    say "Submission ID: #{intake.federal_submission_id}"
  end

  method_option :state, aliases: '-s', desc: 'The relevant state', required: true

  desc 'import_federal_submission_id PERSONA_NAME', 'Imports a submission id as emitted by export_federal_submission_id'
  def import_federal_submission_id(persona_name)
    submission_contents = $stdin.readlines

    # Discard lines that don't begin with magic string
    start_of_contents = submission_contents.index { |item| item.starts_with?('Submission ID: ') }
    submission_id = submission_contents[start_of_contents..].join.delete_prefix('Submission ID: ').chomp

    persona_name = persona_name.downcase

    submission_id_path = "#{__dir__}/../../app/services/state_file/submission_id_lookup.yml"
    say_error "Adding submission id #{options[:submission_id]} to submission_id_lookup.yml for #{persona_name}", :green

    submission_ids = YAML.safe_load_file(submission_id_path)

    submission_ids["#{options[:state]}_#{persona_name}"] = submission_id

    File.write(submission_id_path, YAML.dump(submission_ids.sort.to_h))
  end

  no_tasks do
    def find_intake(id)
      intake_class = ::StateFile::StateInformationService.intake_class(options[:state])
      say_error "Intake class '#{intake_class.name}' selected", :cyan if options[:debug]

      intake_class.find(id)
    end
  end
end
