module PublicPagesHelper
  def enable_online_intake?
    true
  end

  def mixpanel_info(locals)
    mapping = {
      mixpanel_label: 'data-track-click',
      mixpanel_position: 'data-track-attribute-position',
    }
    mapping.reduce({}) do |acc, (k, v)|
      locals[k].present? ? acc.merge("#{v}": locals[k]) : acc
    end
  end
end
