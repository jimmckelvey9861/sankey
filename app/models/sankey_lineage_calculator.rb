class SankeyLineageCalculator
  NODE_ORDER = [
    "Indeed", "Referrals", "Facebook", "Ads", "Craigslist",
    "Applicants", "Reviewed", "Pending", "Interview", "Offer", "Hired", "Lost", "Reject"
  ]

  LAYER_POSITIONS = {
    "Indeed" => 0,
    "Referrals" => 1,
    "Facebook" => 2,
    "Ads" => 3,
    "Craigslist" => 4,
    "Applicants" => 5,
    "Reviewed" => 6,
    "Pending" => 7,
    "Interview" => 8,
    "Offer" => 9,
    "Hired" => 10,
    "Lost" => 11,
    "Reject" => 12
  }

  SOURCE_COLORS = {
    "Indeed" => "#4F81BD",
    "Referrals" => "#9BBB59",
    "Facebook" => "#F79646",
    "Ads" => "#8064A2",
    "Craigslist" => "#C0504D"
  }

  def self.transform(month_data)
    nodes = NODE_ORDER.map { |name| { name: name, layer: LAYER_POSITIONS[name] } }
    node_index = Hash[NODE_ORDER.each_with_index.to_a]

    links = []

    month_data[:sources].each do |source, count|
      links << {
        source: source,
        target: "Applicants",
        value: count,
        origin: source
      }
    end

    month_data[:sources].each do |source, count|
      source_split = count.to_f / month_data[:sources][source]

      links << {
        source: "Applicants",
        target: "Reviewed",
        value: month_data[:reviewed_sources][source],
        origin: source
      }

      links << {
        source: "Applicants",
        target: "Pending",
        value: month_data[:pending_sources][source],
        origin: source
      }
    end

    # Reviewed → Interview, Offer, Reject
    month_data[:reviewed_breakdown].each do |origin, breakdown|
      links << { source: "Reviewed", target: "Interview", value: breakdown[:interview], origin: origin }
      links << { source: "Reviewed", target: "Offer", value: breakdown[:offer], origin: origin }
      links << { source: "Reviewed", target: "Reject", value: breakdown[:reject], origin: origin }
    end

    # Interview → Offer, Reject
    month_data[:interview_breakdown].each do |origin, breakdown|
      links << { source: "Interview", target: "Offer", value: breakdown[:offer], origin: origin }
      links << { source: "Interview", target: "Reject", value: breakdown[:reject], origin: origin }
    end

    # Offer → Hired, Lost
    month_data[:offer_breakdown].each do |origin, breakdown|
      links << { source: "Offer", target: "Hired", value: breakdown[:hired], origin: origin }
      links << { source: "Offer", target: "Lost", value: breakdown[:lost], origin: origin }
    end

    {
      nodes: nodes,
      links: links,
      colors: SOURCE_COLORS
    }
  end
end