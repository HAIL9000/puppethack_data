require 'octokit'

class PuppetHackData

  PullRequest = Struct.new("PullRequest", :repo_owner, :repo_name, :pull_request_number, :merge_status, :author)
  puts "hello world"
end
