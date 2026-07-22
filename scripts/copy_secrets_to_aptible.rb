#!/usr/bin/env ruby

require_relative "../config/environment"

class CopySecrets < Thor
  ENV_TO_APTIBLE = {
    "stg" => "vita-min-staging",
    "prod" => "vita-min-prod",
  }

  def self.exit_on_failure? = true

  desc "copy stg | prod | demo", "Copy secrets from doppler to aptible"

  def copy(environment)
    required_executables = {
      aptible_found: `which aptible`.present?,
      doppler_found: `which doppler`.present?
    }

    case required_executables
    in aptible_found: false, doppler_found: false
      say "Please install doppler & aptible cli tools", :red
      exit
    in aptible_found: false, doppler_found: true
      say "Please install aptible", :red
      exit
    in aptible_found: true, doppler_found: false
      say "Please install doppler", :red
      exit
    else
    end

    unless environment in "stg" | "prod" | "demo"
      say "Invalid environment", :red
      exit
    end

    secrets = JSON.parse(`doppler secrets -p tax-get-your-refund -c #{environment} --json`).transform_values do |value| 
      value['computed']
    end

    values_for_aptible = secrets.map do |key, value| 
      "#{key}=#{value}"
    end.join(' ')

    puts `aptible config:set --app #{ENV_TO_APTIBLE[environment]} #{values_for_aptible}`
  end
end

CopySecrets.start
