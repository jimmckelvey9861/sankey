class SankeyLineageTransformer
  NODE_ORDER = [
    "Indeed", "Referrals", "Facebook", "Ads", "Craigslist",
    "Applicants", "Reviewed", "Pending", "Interview", "Offer",
    "Hired", "Lost", "Reject"
  ]

  def self.transform(month_data)
    nodes = NODE_ORDER.map { |name| { name: name } }
    node_index = NODE_ORDER.each_with_index.to_h
    links = []

    # Sources → Applicants
    month_data[:sources].each do |source, count|
      links << { source: node_index[source], target: node_index["Applicants"], value: count, origin: source }
    end

    # Applicants → Pending / Reviewed
    links << { source: node_index["Applicants"], target: node_index["Pending"], value: month_data[:pending], origin: nil }
    links << { source: node_index["Applicants"], target: node_index["Reviewed"], value: month_data[:reviewed], origin: nil }

    # Reviewed → Reject / Interview / Offer
    links << { source: node_index["Reviewed"], target: node_index["Reject"], value: month_data[:reviewed_reject], origin: nil }
    links << { source: node_index["Reviewed"], target: node_index["Interview"], value: month_data[:reviewed_interview], origin: nil }
    links << { source: node_index["Reviewed"], target: node_index["Offer"], value: month_data[:reviewed_offer], origin: nil }

    # Interview → Offer / Reject
    links << { source: node_index["Interview"], target: node_index["Offer"], value: month_data[:interview_offer], origin: nil }
    links << { source: node_index["Interview"], target: node_index["Reject"], value: month_data[:interview_reject], origin: nil }

    # Offer → Hired / Lost
    links << { source: node_index["Offer"], target: node_index["Hired"], value: month_data[:hired], origin: nil }
    links << { source: node_index["Offer"], target: node_index["Lost"], value: month_data[:lost], origin: nil }

    { nodes: nodes, links: links }
  end
end