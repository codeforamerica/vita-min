require "thor"

class DuplicateDetection < Thor
  desc "strong_matches", "outputs a csv-formatted list of strongly matched duplicates"
  option :"dry-run", desc: "just outputs a csv of expected results when true",
    default: true, aliases: "d"
  def strong_matches
    puts Zendesk::DuplicateIntakeMatcher.run(options["dry-run"])
  end
end
