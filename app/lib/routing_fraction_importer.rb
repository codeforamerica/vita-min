require 'csv'

class RoutingFractionImporter
  ORG_INDEX = 0
  FIRST_STATE_INDEX = 2
  LAST_STATE_INDEX = 43

  # To use, run "RoutingFractionImporter.new.from_csv('state_route.csv')" in console
  def from_csv(filename)
    @successes = []
    @problems = []
    @unfound_vita_partners = []

    @headers = CSV.foreach(filename).first
    return unless headers_aligned? == true

    data = CSV.read(filename, headers: true)

    state_routing_pairs = generate_state_routing_pairs(data)

    create_records_for_state_routing_pairs(state_routing_pairs)

    print_script_messages
    true
  end

  private

  def number_to_percentage(number)
    return nil if number.nil?

    number.to_f / 100.0
  end

  def headers_aligned?
    return true if @headers[ORG_INDEX]&.strip == "Organization Name" || @headers[FIRST_STATE_INDEX]&.strip == "AL" || @headers[LAST_STATE_INDEX]&.strip == "WY"

    puts "Unable to process file b/c headers are not aligned #{@headers[ORG_INDEX]}, #{@headers[FIRST_STATE_INDEX]} and #{@headers[LAST_STATE_INDEX]}"
    false
  end

  def generate_state_routing_pairs(data)
    state_routing_pairs = []

    data.map do |row|
      org_name = row[ORG_INDEX]&.strip
      next unless org_name.present?

      org_state_pair = {
          org_name: org_name,
          state_percent_pairs: []
      }

      (FIRST_STATE_INDEX..LAST_STATE_INDEX).each do |state_index|
        routing_fraction = number_to_percentage(row[state_index]&.strip)
        if routing_fraction&.present?
          state = @headers[state_index]&.strip
          org_state_pair[:state_percent_pairs] << { state: state, routing_fraction: routing_fraction }
        end
      end

      state_routing_pairs << org_state_pair
    end

    state_routing_pairs
  end

  def create_records_for_state_routing_pairs(state_routing_pairs)
    state_routing_pairs.map do |org|
      vita_partner = VitaPartner.where(name: org[:org_name]).first

      unless vita_partner.present?
        @unfound_vita_partners << org[:org_name]
        next
      end

      org[:state_percent_pairs].map do |pair|
        begin
          vps = StateRoutingTarget.find_or_create_by!(state: pair[:state], vita_partner: vita_partner)
          previous_routing_fraction = vps.routing_fraction
          vps.update!(routing_fraction: pair[:routing_fraction])

          record_status =
              if vps.new_record?
                "Created"
              elsif previous_routing_fraction != pair[:routing_fraction]
                "Updated"
              else
                "No change to"
              end

          @successes << "#{record_status} StateRoutingTarget (#{vps.id}) record with [#{vps.state}, #{vps.routing_fraction}] for \"#{vps.vita_partner.name}\" (#{vps.vita_partner.id})"
        rescue => e
          @problems << "SKIPPED Unable to create/update StateRoutingTarget with [#{pair[:state]}, #{pair[:routing_fraction]}] for \"#{vita_partner.name}\" (#{vita_partner.id}) because: #{e.message}"
        end
      end
    end
  end

  def print_script_messages
    @problems << "SKIPPED Unable to find VitaPartner for organization names:\n#{@unfound_vita_partners.join(", ")}"
    puts "**** #{@successes.length} SUCCESSES ****"
    puts @successes
    puts "**** LOOK INTO THESE #{@problems.length} ISSUES ****"
    puts @problems
  end
end
