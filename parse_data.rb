require 'csv'

class ParseData
  REPO = 0
  PR_NUMBER = 1
  TITLE = 2
  AUTHOR_HANDLE = 3
  AUTHOR_NAME = 4
  PUPPET_LABS = 5
  OPENED_AT = 6
  CLOSED_AT = 7
  PUPPETHACK = 8

  pr_data = CSV.read("pr_stats.csv")
  pr_data.delete_at(0)

  pull_requests_by_date = {}

  # Generate a hash of pull requests sorted by their date
  pr_data.each do |pr|
    date = pr[OPENED_AT][0..9]

    if !pull_requests_by_date[date]
      pull_requests_by_date[date] = []
    end

    pull_requests_by_date[date] << [pr[REPO], pr[PR_NUMBER], pr[PUPPET_LABS], pr[PUPPETHACK]]
  end

  total_prs = 0
  total_days = 0

  community_total_prs = 0
  puppethack_total_prs = 0

  pull_requests_by_date.each do |date, pr_array|
    community_total = 0

    total_prs += pr_array.length
    total_days += 1

    pr_array.each do |pr|
      if pr[2] == 'false'
        community_total_prs += 1
        community_total += 1
      end

      if pr[3] == 'true'
        puppethack_total_prs += 1
      end
    end
  end


  average_per_day = total_prs.fdiv(total_days).round(1)
  average_per_day_community = community_total_prs.fdiv(total_days).round(1)
  percent_community = ((community_total_prs.fdiv(total_prs))*100).round(2)
  percent_puppethack = ((puppethack_total_prs.fdiv(total_prs))*100).round(2)

  puts <<-RESULTS

  Okay! Let's analyze the data in pr_stats.csv...

  Here's a summary of the data!

  Total pull requests: #{total_prs}
  Total from community: #{community_total_prs}
  Number of days in data given: #{total_days}
  Average per day: #{average_per_day}
  Community average per day: #{average_per_day_community} 
  Percentage from community: #{percent_community}%
  Total with 'puppethack' in title: #{puppethack_total_prs}
  Percentage with 'puppethack' in title: #{percent_puppethack}

 RESULTS
end
