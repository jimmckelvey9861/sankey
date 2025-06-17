class SankeyLineageTransformer
  NODE_ORDER = [
    "Indeed", "Facebook", "Referrals", "Craigslist", "Ads",
    "Applicants", "Reviewed", "Pending",
    "Interview", "Offer", "Hired", "Lost", "Reject"
  ]

  NODE_X_POSITIONS = {
    "Indeed" => 0.0, "Referrals" => 0.0, "Craigslist" => 0.0, "Ads" => 0.0, "Facebook" => 0.0,
    "Applicants" => 0.15,
    "Reviewed" => 0.3, "Pending" => 0.3,
    "Interview" => 0.45,
    "Offer" => 0.6,
    "Hired" => 0.8, "Lost" => 0.8, "Reject" => 0.8
  }

  NODE_Y_POSITIONS = {
    "Indeed" => 0.05,
    "Referrals" => 0.15,
    "Facebook" => 0.25,
    "Ads" => 0.35,
    "Craigslist" => 0.45,
    "Applicants" => 0.55,
    "Reviewed" => 0.65,
    "Pending" => 0.75,
    "Interview" => 0.35,
    "Offer" => 0.5,
    "Hired" => 0.2,
    "Lost" => 0.35,
    "Reject" => 0.65
  }

  COLORS = {
    "Indeed" => "#1f77b4",
    "Facebook" => "#ff7f0e",
    "Referrals" => "#2ca02c",
    "Craigslist" => "#d62728",
    "Ads" => "#9467bd"
  }

  def self.transform(month_data)
    node_indices = NODE_ORDER.each_with_index.to_h
    links = []

    month_data[:sources].each do |source, count|
      links << { source: node_indices[source], target: node_indices["Applicants"], value: count, color: COLORS[source] }
    end

    month_data[:sources].each do |source, source_count|
      ratio = source_count.to_f / month_data[:applicants]

      links << { source: node_indices["Applicants"], target: node_indices["Reviewed"], value: (month_data[:reviewed] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Applicants"], target: node_indices["Pending"], value: (month_data[:pending] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Reviewed"], target: node_indices["Interview"], value: (month_data[:reviewed_interview] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Reviewed"], target: node_indices["Offer"], value: (month_data[:reviewed_offer] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Reviewed"], target: node_indices["Reject"], value: (month_data[:reviewed_reject] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Interview"], target: node_indices["Offer"], value: (month_data[:interview_offer] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Interview"], target: node_indices["Reject"], value: (month_data[:interview_reject] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Offer"], target: node_indices["Hired"], value: (month_data[:hired] * ratio).round, color: COLORS[source] }
      links << { source: node_indices["Offer"], target: node_indices["Lost"], value: (month_data[:lost] * ratio).round, color: COLORS[source] }
    end

    {
      nodes: NODE_ORDER,
      node_x: NODE_ORDER.map { |name| NODE_X_POSITIONS[name] },
      node_y: NODE_ORDER.map { |name| NODE_Y_POSITIONS[name] },
      links: links
    }
  end
end