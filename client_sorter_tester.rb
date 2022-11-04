filter_tests = [
  {},
  {year: 2019},
  {year: 2021, status: 'intake'},
  {year: 2021, status: 'file_accepted'},
  {year: 2021, active_returns: true},
  {year: 2021, service_type: 'drop_off'},
  {last_contact: 'approaching_sla'},
  {unassigned: true},
  {assigned_to_me: true},
  {search: 'lucky'},
  {greetable: true},
  {used_navigator: true},
  {ctc_client: true},
  {year: 2021, search: 'lucky'},
  {year: 2021, column: :state_of_residence},
  {year: 2021, column: :email_address},
]

$q_first_page = -> (sorter) { sorter.filtered_and_sorted_clients.limit(25).first(25).length }
$q_count = -> (sorter) { sorter.filtered_and_sorted_clients.count }

def perform_test(filters, sorter_slow, sorter_fast, u)
  this_result = {test_name: filters.inspect}
  query = if filters[:column].present?
    $q_first_page
  else
    $q_count
  end
  2.times { query.call(sorter_slow) }
  this_result[:slow_time] = Benchmark.realtime { this_result[:slow_result] = query.call(sorter_slow) }

  2.times { query.call(sorter_fast) }
  this_result[:fast_time] = Benchmark.realtime { this_result[:fast_result] = query.call(sorter_fast) }

  ref_time = Date.parse('2022-11-04')
  sorter_fast_accurate = ClientSorterFaster.new(Client.where('clients.created_at < ?', ref_time).left_outer_joins(:tax_returns).where.not(tax_returns: { id: nil }), u, filters, {})
  if filters[:column].present?
    this_result[:fast_result_accurate] = sorter_fast_accurate.filtered_and_sorted_clients.distinct.limit(25).first(25).length
  else
    this_result[:fast_result_accurate] = sorter_fast_accurate.filtered_and_sorted_clients.distinct.count
  end

  this_result
end


ref_time = Date.parse('2022-11-04')
users = [User.find_by(role_type: 'AdminRole'), User.find_by(role_type: 'GreeterRole')]
users.each do |u|
  unless u
    puts "NO USER FOUND"
    next
  end
  puts "USER: #{u.email}"
  table_rows = []

  filter_tests.each do |filters|
    sorter_slow = ClientSorter.new(Client.joins(:tax_returns).where('clients.created_at < ?', ref_time), u, filters, {})
    sorter_fast = ClientSorterFaster.new(Client.where('clients.created_at < ?', ref_time), u, filters, {})

    result = perform_test(filters, sorter_slow, sorter_fast, u)
    table_row = []
    table_row << filters.inspect

    emoji = if result[:slow_result] == 0 || result[:fast_result_accurate] == 0
      '😕'
    elsif result[:slow_result] == result[:fast_result_accurate]
      '✅'
    else
      '❌'
    end
    table_row << "#{emoji} (#{result[:slow_result]}/#{result[:fast_result]}/#{result[:fast_result_accurate]})"

    speed = if result[:slow_time] > result[:fast_time]
      "%.2fx faster" % ((result[:slow_time] / result[:fast_time]))
    else
      "%.2fx slower" % ((result[:fast_time] / result[:slow_time]))
    end
    table_row << "#{speed} (#{result[:slow_time]} / #{result[:fast_time]})"

    print '.'
    table_rows << table_row
  end

  require 'terminal-table'
  puts
  puts Terminal::Table.new :rows => table_rows
end
