require 'octokit'
require 'optparse'

class PuppetHackData

  options = {}
  repos = []


  OptionParser.new do |opts|
    opts.on("--oauth_token TOKEN") do |token|
      options[:token] = token
    end

    opts.on("--start_date DATE") do |date|
      options[:start_date] = date
    end

    opts.on("--end_date DATE") do |date|
      options[:end_date] = date
    end

    opts.on("--closed") do
      options[:closed] = true
    end
  end.parse!

  ARGV.each do |arg|
    repos << arg
  end

  puts repos
end
