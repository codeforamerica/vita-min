class PopulateVitaPartnerStateRoutingFractions < ActiveRecord::Migration[6.0]
  # class StateRoutingTarget < ActiveRecord::Base
  #   belongs_to :vita_partner
  # end
  # class VitaPartner < ActiveRecord::Base; end
  # class Site < VitaPartner; end
  # class Organization < VitaPartner; end

  def up
    # for every StateRoutingTarget (formerly VitaPartnerState)
    #
    # if it has a vita_partner that is an independent org
    #  * just create the VPSRF, pointed back at this SRT with the routing fraction copied over

    # if it has a vita_partner that is a site
    #  * move the SRT to point at that site's parent org
    #  * make a VPSRF for the site

    # Next steps, for, when we try to create routing_target_id instead of vita_partner_id
    # * for every SRT
    #   * if the vita partner is an org
    #     * if it's independent, copy 'vita_partner' as the routing target
    #     * if it's in a coalition, put the vita_partner.coalition as the routing target
    #   * if the vita partner is a site
    #     * copy 'vita_partner.parent_organization' as the routing target

    StateRoutingTarget.includes(:vita_partner).each do |srt|
      VitaPartnerStateRoutingFraction.create(state_routing_target: srt, vita_partner: srt.vita_partner, routing_fraction: srt.routing_fraction)
    end
  end

  def down
    # sorry no
  end
end
