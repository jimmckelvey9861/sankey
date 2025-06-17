class SamplePipelineDataGenerator
  def self.generate_year_data(year = Date.today.year)
    (1..12).map { |month| generate_month_data(Date.new(year, month, 1)) }
  end

  def self.generate_month_data(date)
    # Stage 0 — Sources
    sources = {
      "Indeed" => rand(100..200),
      "Referrals" => rand(50..100),
      "Craigslist" => rand(20..50),
      "Ads" => rand(30..60),
      "Facebook" => rand(40..80)
    }

    applicants = sources.values.sum

    # Stage 1 — Applicants → Pending / Reviewed
    pending = (applicants * rand(0.1..0.3)).to_i
    reviewed = applicants - pending

    # Stage 2 — Reviewed → Reject / Interview / Offer
    reviewed_reject = (reviewed * rand(0.1..0.3)).to_i
    reviewed_offer = (reviewed * rand(0.05..0.15)).to_i
    reviewed_interview = reviewed - reviewed_reject - reviewed_offer

    # Stage 3 — Interview → Offer / Reject
    interview_offer = (reviewed_interview * rand(0.5..0.7)).to_i
    interview_reject = reviewed_interview - interview_offer

    # Stage 4 — Offer → Hired / Lost
    total_offer = reviewed_offer + interview_offer
    hired = (total_offer * rand(0.6..0.8)).to_i
    lost = total_offer - hired

    {
      month: date.strftime("%B %Y"),
      sources: sources,
      applicants: applicants,
      pending: pending,
      reviewed: reviewed,
      reviewed_reject: reviewed_reject,
      reviewed_offer: reviewed_offer,
      reviewed_interview: reviewed_interview,
      interview_offer: interview_offer,
      interview_reject: interview_reject,
      total_offer: total_offer,
      hired: hired,
      lost: lost
    }
  end
end