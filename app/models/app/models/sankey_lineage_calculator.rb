class SankeyLineageCalculator
  NODE_ORDER = [
    "Indeed", "Referrals", "Craigslist", "Ads", "Facebook",
    "Applicants", "Reviewed", "Pending", "Interview", "Offer",
    "Hired", "Lost", "Reject"
  ]

  NODE_X = {
    "Indeed" => 0, "Referrals" => 0, "Craigslist" => 0, "Ads" => 0, "Facebook" => 0,
    "Applicants" => 1,
    "Reviewed" => 2, "Pending" => 2,
    "Interview" => 3,
    "Offer" => 4,
    "Hired" => 5, "Lost" => 5, "Reject" => 5
  }

  NODE_Y = {
    "Indeed" => 0, "Referrals" => 1, "Craigslist" => 2, "Ads" => 3, "Facebook" => 4,
    "Applicants" => 2,
    "Reviewed" => 0, "Pending" => 1,
    "Interview" => 0,
    "Offer" => 0,
    "Hired" => 0, "Lost" => 1, "Reject" => 2
  }

  def self.transform(month_data)
    node_index = NODE_ORDER.each_with_index.to_h

    links = []

    month_data[:sources].each do |source, count|
      links << [node_index[source], node_index["Applicants"], count]
    end

    links << [node_index["Applicants"], node_index["Pending"], month_data[:pending]]
    links << [node_index["Applicants"], node_index["Reviewed"], month_data[:reviewed]]

    links << [node_index["Reviewed"], node_index["Reject"], month_data[:reviewed_reject]]
    links << [node_index["Reviewed"], node_index["Interview"], month_data[:reviewed_interview]]
    links << [node_index["Reviewed"], node_index["Offer"], month_data[:reviewed_offer]]

    links << [node_index["Interview"], node_index["Offer"], month_data[:interview_offer]]
    links << [node_index["Interview"], node_index["Reject"], month_data[:interview_reject]]

    links << [node_index["Offer"], node_index["Hired"], month_data[:hired]]
    links << [node_index["Offer"], node_index["Lost"], month_data[:lost]]

    {
      nodes: NODE_ORDER,
      node_x: NODE_ORDER.map { |n| NODE_X[n] },
      node_y: NODE_ORDER.map { |n| NODE_Y[n] },
      links: links
    }
  end
end
