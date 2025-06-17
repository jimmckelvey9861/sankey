class SankeyLineageCalculator
  SOURCES = ["Indeed", "Facebook", "Referrals", "Craigslist", "Ads"]

  SOURCE_COLORS = {
    "Indeed" => [31, 119, 180],
    "Facebook" => [255, 127, 14],
    "Referrals" => [44, 160, 44],
    "Craigslist" => [214, 39, 40],
    "Ads" => [148, 103, 189]
  }

  VERTICAL_ORDER = [
    "Applicants", "Reviewed", "Pending", "Interview", "Offer", "Hired", "Lost", "Reject"
  ]

  NODE_ORDER = SOURCES + VERTICAL_ORDER

  def self.transform(month_data)
    nodes = NODE_ORDER
    node_lookup = nodes.each_with_index.to_h

    # 1. Build full lineage hash per source
    lineage = SOURCES.map { |s| [s, { applicants: month_data[:sources][s] }] }.to_h

    # 2. Forward propagate proportions
    SOURCES.each do |src|
      total_app = lineage[src][:applicants].to_f

      lineage[src][:pending]  = total_app * month_data[:pending] / month_data[:applicants]
      lineage[src][:reviewed] = total_app * month_data[:reviewed] / month_data[:applicants]

      lineage[src][:reviewed_reject]  = lineage[src][:reviewed] * month_data[:reviewed_reject] / month_data[:reviewed]
      lineage[src][:reviewed_offer]   = lineage[src][:reviewed] * month_data[:reviewed_offer] / month_data[:reviewed]
      lineage[src][:reviewed_interview] = lineage[src][:reviewed] * month_data[:reviewed_interview] / month_data[:reviewed]

      lineage[src][:interview_offer]  = lineage[src][:reviewed_interview] * month_data[:interview_offer] / month_data[:reviewed_interview]
      lineage[src][:interview_reject] = lineage[src][:reviewed_interview] * month_data[:interview_reject] / month_data[:reviewed_interview]

      lineage[src][:total_offer] = lineage[src][:reviewed_offer] + lineage[src][:interview_offer]

      lineage[src][:hired] = lineage[src][:total_offer] * month_data[:hired] / month_data[:total_offer]
      lineage[src][:lost]  = lineage[src][:total_offer] * month_data[:lost]  / month_data[:total_offer]
    end

    # 3. Build links
    links = []

    SOURCES.each do |src|
      links << blended_link(node_lookup[src], node_lookup["Applicants"], lineage[src][:applicants], [src])
      links << blended_link(node_lookup["Applicants"], node_lookup["Pending"], lineage[src][:pending], [src])
      links << blended_link(node_lookup["Applicants"], node_lookup["Reviewed"], lineage[src][:reviewed], [src])
      links << blended_link(node_lookup["Reviewed"], node_lookup["Reject"], lineage[src][:reviewed_reject], [src])
      links << blended_link(node_lookup["Reviewed"], node_lookup["Interview"], lineage[src][:reviewed_interview], [src])
      links << blended_link(node_lookup["Reviewed"], node_lookup["Offer"], lineage[src][:reviewed_offer], [src])
      links << blended_link(node_lookup["Interview"], node_lookup["Offer"], lineage[src][:interview_offer], [src])
      links << blended_link(node_lookup["Interview"], node_lookup["Reject"], lineage[src][:interview_reject], [src])
      links << blended_link(node_lookup["Offer"], node_lookup["Hired"], lineage[src][:hired], [src])
      links << blended_link(node_lookup["Offer"], node_lookup["Lost"], lineage[src][:lost], [src])
    end

    {
      nodes: nodes,
      node_x: compute_node_x(nodes),
      node_y: compute_node_y(nodes),
      links: links
    }
  end

  def self.blended_link(source, target, value, contributors)
    rgb = contributors.map { |src| SOURCE_COLORS[src] }
                      .transpose
                      .map { |channel| (channel.sum / contributors.size).round }

    {
      source: source,
      target: target,
      value: value,
      color: "rgb(#{rgb[0]},#{rgb[1]},#{rgb[2]})"
    }
  end

  def self.compute_node_x(nodes)
    nodes.map do |name|
      SOURCES.include?(name) ? 0.0 :
        name == "Applicants" ? 0.15 : 0.3
    end
  end

  def self.compute_node_y(nodes)
    nodes.map do |name|
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
  end
end