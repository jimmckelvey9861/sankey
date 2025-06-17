class SankeyDataTransformer
  NODE_ORDER = [
    "Indeed", "Referrals", "Facebook", "Ads", "Craigslist",
    "Applicants", "Pending", "Reviewed", "Interview", "Offer", "Hired", "Lost", "Reject"
  ]

  NODE_VERTICAL_ORDER = {
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
    "Indeed" => "#1f77b4",
    "Referrals" => "#2ca02c",
    "Facebook" => "#ff7f0e",
    "Ads" => "#9467bd",
    "Craigslist" => "#d62728"
  }

  def self.transform(month_data)
    node_names = NODE_ORDER
    node_index = node_names.each_with_index.to_h
    links = []

    month_data[:sources].each do |source, count|
      links << { source: source, target: "Applicants", value: count, origin: source }
    end

    total_sources = month_data[:sources].values.sum.to_f

    distribute = lambda do |source_stage, target_stage, total_value|
      month_data[:sources].each do |origin, count|
        portion = (count / total_sources * total_value).round
        links << { source: source_stage, target: target_stage, value: portion, origin: origin }
      end
    end

    distribute.call("Applicants", "Pending", month_data[:pending])
    distribute.call("Applicants", "Reviewed", month_data[:reviewed])
    distribute.call("Reviewed", "Reject", month_data[:reviewed_reject])
    distribute.call("Reviewed", "Interview", month_data[:reviewed_interview])
    distribute.call("Reviewed", "Offer", month_data[:reviewed_offer])
    distribute.call("Interview", "Offer", month_data[:interview_offer])
    distribute.call("Interview", "Reject", month_data[:interview_reject])
    distribute.call("Offer", "Hired", month_data[:hired])
    distribute.call("Offer", "Lost", month_data[:lost])

    node_flows = Hash.new { |h, k| h[k] = Hash.new(0) }

    links.each do |l|
      node_flows[l[:target]][l[:origin]] += l[:value]
    end

    blended_node_colors = {}
    node_flows.each do |node, origins|
      blended_node_colors[node] = blend_colors(origins)
    end

    {
      nodes: node_names,
      links: links,
      colors: SOURCE_COLORS,
      node_colors: blended_node_colors,
      vertical_order: NODE_VERTICAL_ORDER
    }
  end

  def self.blend_colors(origins)
    total = origins.values.sum.to_f
    r, g, b = 0, 0, 0

    origins.each do |source, value|
      sr, sg, sb = hex_to_rgb(SOURCE_COLORS[source])
      weight = value / total
      r += sr * weight
      g += sg * weight
      b += sb * weight
    end

    rgb_to_hex(r.round, g.round, b.round)
  end

  def self.hex_to_rgb(hex)
    hex = hex.delete("#")
    [hex[0..1], hex[2..3], hex[4..5]].map { |c| c.to_i(16) }
  end

  def self.rgb_to_hex(r, g, b)
    "#%02x%02x%02x" % [r, g, b]
  end
end