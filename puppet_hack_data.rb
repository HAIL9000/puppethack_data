require 'octokit'
require 'optparse'

class PuppetHackData

  @options = {}
  @repos = []
  # The list of repos we want to track for puppet hack
  @default_repos = ['puppetlabs/facter', 'puppetlabs/puppet', 'puppetlabs/hiera']

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

  puts @repos

end
