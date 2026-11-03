# Summarize one or two JMeter runs per request label, side by side.
#   ruby summarize_results.rb baseline fix                 # newest results/*-baseline-*.jtl vs newest *-fix-*.jtl
#   ruby summarize_results.rb results/a.jtl results/b.jtl  # or exact files
require 'csv'

def resolve(arg)
  return arg if File.file?(arg)

  newest = Dir.glob(File.join(__dir__, 'results', "*-#{arg}-*.jtl")).max_by { |f| File.mtime(f) }
  newest || abort("No results file or label matching '#{arg}' (looked for results/*-#{arg}-*.jtl)")
end

def load(path)
  rows = CSV.read(path, headers: true)
  rows.group_by { |r| r['label'] }.transform_values do |samples|
    times = samples.map { |s| s['elapsed'].to_i }.sort
    pct = ->(p) { times[((times.size - 1) * p).round] }
    errors = samples.count { |s| s['success'] != 'true' }
    span = (samples.map { |s| s['timeStamp'].to_i }.minmax.then { |a, b| (b - a) / 1000.0 })
    { count: samples.size, p50: pct.(0.5), p90: pct.(0.9), p95: pct.(0.95), max: times.last,
      errors: errors, per_min: span.positive? ? (samples.size / span * 60).round(1) : samples.size }
  end
end

abort 'usage: ruby summarize_results.rb LABEL_OR_FILE [LABEL_OR_FILE]   e.g. baseline fix' if ARGV.empty?
files = ARGV.first(2).map { |arg| resolve(arg) }
data = files.map { |f| load(f) }
labels = data.flat_map(&:keys).uniq.sort
fmt = ->(s) { s ? format('%5d %5d %5d %4d%%', s[:count], s[:p50], s[:p95], (100.0 * s[:errors] / s[:count]).round) : format('%5s %5s %5s %5s', '-', '-', '-', '-') }

puts files.each_with_index.map { |f, i| "#{i.zero? ? 'A' : 'B'} = #{File.basename(f)}" }
header = format('%-34s', 'request') + files.each_index.map { |i| format('  %-24s', "#{i.zero? ? 'A' : 'B'}: n   p50   p95  err") }.join
header += '  p50 change' if files.size == 2
puts header
labels.each do |label|
  stats = data.map { |d| d[label] }
  line = format('%-34s', label[0, 34]) + stats.map { |s| "  #{fmt.(s)}   " }.join
  if files.size == 2 && stats.all? && stats[0][:p50].positive?
    line += format('%+d%%', ((stats[1][:p50] - stats[0][:p50]) * 100.0 / stats[0][:p50]).round)
  end
  puts line
end
