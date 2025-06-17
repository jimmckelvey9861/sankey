class SankeyDataTransformer
  VERTICAL_ORDER = [
    "Applicants",
    "Reviewed",
    "Pending",
    "Interview",
    "Offer",
    "Hired",
    "Lost",
    "Reject"
  ]

  NODE_ORDER = [
    "Indeed", "Facebook", "Referrals", "Craigslist", "Ads"
  ] + VERTICAL_ORDER

  SOURCE_COLORS = {
    "Indeed" => "#1f77b4",
    "Facebook" => "#ff7f0e",
    "Referrals" => "#2ca02c",
    "Craigslist" => "#d62728",
    "Ads" => "#9467bd"
  }

  def self.transform(month_data)
    nodes = NODE_ORDER

    # Horizontal positions: sources (0), applicants (0.15), pipeline stages (0.3 → 1.0)
    node_x = nodes.map do |name|
      if SOURCE_COLORS.key?(name)
        0.0
      elsif name == "Applicants"
        0.15
      else
        0.3
      end
    end

    # Vertical positions calculated dynamically
    node_y = nodes.map do |name|
      if VERTICAL_ORDER.include?(name)
        idx = VERTICAL_ORDER.index(name)
        idx.to_f / (VERTICAL_ORDER.size - 1)
      else
        case name
        when "Indeed" then 0.0
        when "Facebook" then 0.2
        when "Referrals" then 0.4
        when "Craigslist" then 0.6
        when "Ads" then 0.8
        else 0.5
        end
      end
    end

    node_lookup = nodes.each_with_index.to_h
    links = []

    # Sources → Applicants
    month_data[:sources].each do |source, count|
      links << { source: node_lookup[source], target: node_lookup["Applicants"], value: count, color: SOURCE_COLORS[source] }
    end

    # Applicants → Pending / Reviewed
    links << { source: node_lookup["Applicants"], target: node_lookup["Pending"], value: month_data[:pending], color: "#cccccc" }
    links << { source: node_lookup["Applicants"], target: node_lookup["Reviewed"], value: month_data[:reviewed], color: "#cccccc" }

    # Reviewed → Reject / Interview / Offer
    links << { source: node_lookup["Reviewed"], target: node_lookup["Reject"], value: month_data[:reviewed_reject], color: "#999999" }
    links << { source: node_lookup["Reviewed"], target: node_lookup["Interview"], value: month_data[:reviewed_interview], color: "#999999" }
    links << { source: node_lookup["Reviewed"], target: node_lookup["Offer"], value: month_data[:reviewed_offer], color: "#999999" }

    # Interview → Offer / Reject
    links << { source: node_lookup["Interview"], target: node_lookup["Offer"], value: month_data[:interview_offer], color: "#999999" }
    links << { source: node_lookup["Interview"], target: node_lookup["Reject"], value: month_data[:interview_reject], color: "#999999" }

    # Offer → Hired / Lost
    links << { source: node_lookup["Offer"], target: node_lookup["Hired"], value: month_data[:hired], color: "#999999" }
    links << { source: node_lookup["Offer"], target: node_lookup["Lost"], value: month_data[:lost], color: "#999999" }

    {
      nodes: nodes,
      node_x: node_x,
      node_y: node_y,
      links: links
    }
  end
end