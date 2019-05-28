# service used to interact with GitHub API

class GithubService
  GITHUB_URL    = 'http://www.github.com'.freeze
  GITHUB_CLIENT = Github.new autopagination: true
  PULL_REQUEST_METHODS = %w[comments reviews].freeze
  DAYS_AFTER_SUNDAY = {
    'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3,
    'thursday' => 4, 'friday' => 5, 'saturday' => 6
  }.freeze

  class << self
    def repos(org)
      from_sunday, to_saturday = past_week
      repos = GITHUB_CLIENT.repos.all org: org

      repos.filter do |repo|
        (from_sunday..to_saturday).cover? repo['pushed_at']
      end
    end

    def pulls(org, repo_name)
      GITHUB_CLIENT.pull_requests.all(user: org, repo: repo_name)
    end

    def pulls_between(from, to, org, repo_name)
      date_range = from..to
      pulls = pulls(org, repo_name)

      pulls.select { |pull| date_range.cover? pull['created_at'] }
    end

    def pulls_since(date, org, repo_name)
      pulls_between(date, Time.now, org, repo_name)
    end

    def past_week_pulls(org, repo_name)
      from_sunday, to_saturday = past_week
      pulls_between(from_sunday, to_saturday, org, repo_name)
    end

    PULL_REQUEST_METHODS.each do |method|
      define_method(method.to_sym) do |org, repo_name, pull_number|
        GITHUB_CLIENT.pull_requests
                     .send(method)
                     .list(org, repo_name, pull_number)
      end
    end

    def day
      Date.today.strftime("%A").downcase
    end

    def past_week
      from_sunday = Date.today - (7 + DAYS_AFTER_SUNDAY[day])
      to_saturday = from_sunday + DAYS_AFTER_SUNDAY['saturday']

      [from_sunday.to_time, to_saturday.to_time]
    end
  end
end
