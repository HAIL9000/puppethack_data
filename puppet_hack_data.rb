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
  @end_time = Time.new(2015,07,15,00,00)
  @start_time = Time.new(2015,07,01,00,00)

  OptionParser.new do |opts|
    opts.on("--oauth_token TOKEN") do |token|
      @options[:token] = token
    end

    opts.on("--start_date DATE") do |date|
      @options[:start_date] = date
    end

    opts.on("--end_date DATE") do |date|
      @options[:end_date] = date
    end

    opts.on("--closed") do
      @options[:closed] = true
    end

    opts.on("--repo_owner OWNER") do |owner|
      @options[:repo_owner] = owner
    end

    opts.on("--github_token TOKEN") do |token|
      @options[:token] = token
    end

  end.parse!

  ARGV.each do |arg|
    @repos << arg
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

  @repos.each do |repo|
    puts "NOW COLLECTING DATA FOR: #{repo}"

    pulls = @client.pulls(repo)
    pulls.select{ |pull| pull[:updated_at] < @end_time and pull[:updated_at] > @start_time }

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

  puts @pull_requests
end
