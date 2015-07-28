require 'octokit'
require 'optparse'
require 'csv'

class PuppetHackData

  @options = {}
  @repos = []
  # The list of repos we want to track for puppet hack
  @default_repos = ['puppetlabs/puppet', 'puppetlabs/facter', 'puppetlabs/hiera', 'puppetlabs/r10k', 'puppetlabs/puppet-server',
                    'puppetlabs/beaker', 'puppetlabs/marionette-collective', 'puppetlabs/puppetdb', 'puppetlabs/razor',
                    'puppetlabs/trapperkeeper', 'puppetlabs/puppetlabs-vcsrepo', 'puppetlabs/puppetlabs-stdlib', 'puppetlabs/puppetlabs-apt',
                    'puppetlabs/puppetlabs-concat', 'puppetlabs/puppetlabs-firewall', 'puppetlabs/puppetlabs-apache',
                    'puppetlabs/puppetlabs-postgresql', 'puppetlabs/puppetlabs-ntp', 'puppetlabs/puppetlabs-inifile',
                    'puppetlabs/puppetlabs-mysql', 'puppetlabs/puppetlabs-java', 'puppetlabs/puppetlabs-haproxy', 'puppetlabs/puppetlabs-java_ks',
                    'puppetlabs/puppetlabs-registry', 'puppetlabs/puppetlabs-powershell', 'puppetlabs/puppetlabs-tomcat',
                    'puppetlabs/puppetlabs-reboot', 'puppetlabs/puppetlabs-acl', 'puppetlabs/puppetlabs-aws', 'puppetlabs/puppetlabs-docker_platform']
  @pull_requests = []
  # puppet hack takes place on 2015-07-30 from 4am-4pm
  @end_time = Time.new(2015,07,30,04,00)
  @start_time = Time.new(2015,07,30,16,00)

  OptionParser.new do |opts|
    opts.on("--github_token TOKEN") do |token|
      @options[:token] = token
    end

    opts.on("--start_date DATE") do |date|
      @options[:start_date] = date
    end

    opts.on("--end_date DATE") do |date|
      @options[:end_date] = date
    end

    opts.on("--open_only") do
      @options[:open_only] = true
    end

    opts.on("--repo_owner OWNER") do |owner|
      @options[:repo_owner] = owner
    end
  end.parse!

  ARGV.each do |arg|
    @repos << arg
  end

  if @options[:start_date]
    sta = @options[:start_date].split(":")
    @start_time = Time.new(sta[0], sta[1], sta[2], sta[3], sta[4])
  end

  if @options[:end_date]
    eta = @options[:end_date].split(":")
    @end_time = Time.new(eta[0], eta[1], eta[2], eta[3], eta[4])
  end

  if @options[:token].nil?
    raise "ERROR: You must provide a GitHub authorization token via --github_token"
  end

  if @repos.empty?
    @repos = @default_repos
  else
    if @options[:repo_owner]
      @repos.collect! { |repo| "#{@options[:repo_owner]}/#{repo}" }
    else
      raise "ERROR: You must provide a repository owner via --repo_owner"
    end
  end

  @client = Octokit::Client.new(:access_token => @options[:token])

  puts "Let's collect some pull request data!"
  @repos.each do |repo|
    puts "Hang on, I'm collecting data for #{repo}..."

    if @options[:open_only]
      pulls = @client.pulls(repo, {:state => 'open'})
    else
      pulls = @client.pulls(repo, {:state => 'all'})
    end

    pulls.select! { |pull| (pull[:updated_at] < @end_time) && (pull[:updated_at] > @start_time) }

    pulls.each do |pr|
      @pull_requests << {:repo => repo,
        :number => pr.number,
        :title => pr.title,
        :author => pr.user[:login],
        :opened => pr.created_at,
        :closed  => pr.closed_at,
        :puppethack => (pr.title.index(/puppethack/i) ? true : false)}
    end
  end

  CSV.open("pr_stats.csv", "wb") do |csv|
    csv << ["Repository", "Number", "Title", "Author", "Opened At", "Closed At", "Contains [puppethack]"]
    @pull_requests.each do |pr|
      csv << [pr[:repo], pr[:number], pr[:title], pr[:author], pr[:opened], pr[:closed], pr[:puppethack]]
    end
  end

  puts "All done! I collected data for #{@pull_requests.size} pull requests! \nCheck out pr_stats.csv for the full report. Thank you!"
end
