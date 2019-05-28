# service used to interact with GitHub API

class GithubService
  GITHUB_URL    = 'http://www.github.com'.freeze
  GITHUB_CLIENT = Github.new autopagination: true
  PULL_REQUEST_METHODS = %w[comments reviews].freeze

  class << self
    def repos(org)
      GITHUB_CLIENT.repos.all org: org
    end

    def pulls(org, repo_name)
      GITHUB_CLIENT.pull_requests.all(user: org, repo: repo_name)
    end

    def pulls_since(date, org, repo_name)
      date_range = date..Date.today
      pulls = pulls(org, repo_name)

      pulls.select { |pull| date_range.cover? Date.parse(pull['created_at']) }
    end

    def past_week_pulls(org, repo_name)
      last_week_date = Date.today - 7
      pulls_since(last_week_date, org, repo_name)
    end

    PULL_REQUEST_METHODS.each do |method|
      define_method(method.to_sym) do |org, repo_name, pull_number|
        GITHUB_CLIENT.pull_requests
                     .send(method)
                     .list(org, repo_name, number: pull_number)
      end
    end
  end
end
