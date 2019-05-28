class ScoreboardController < ApplicationController
  def by_org
    org          = params[:org]
    repos        = GithubService.repos(org)
    pulls        = org_pull_requests(org, repos)
    reviews      = org_reviews(org, pulls)
    comments     = org_comments(org, pulls)
    @contributors = org_contributors(pulls, reviews, comments)

    render template: 'scoreboard/by_org.json.jbuilder'
  end

  private

  def org_pull_requests(org, repos)
    pull_requests = []

    repos.each do |repo|
      pull_requests << GithubService.past_week_pulls(org, repo['name'])
    end

    pull_requests.flatten
  end

  def org_comments(org, pulls)
    pulls.each_with_object([]) do |pull, comments|
      comments << GithubService.comments(org,
                                         pull['head']['repo']['name'],
                                         pull['number'].to_i)
    end.flatten
  end

  def org_reviews(org, pulls)
    pulls.each_with_object([]) do |pull, reviews|
      reviews << GithubService.reviews(org,
                                       pull['head']['repo']['name'],
                                       pull['number'].to_i)
    end.flatten
  end

  def org_contributors(pulls, reviews, comments)
    contributors = []

    pulls.each do |pull|
      username = pull['user']['login']
      contributor = contributors.find { |hash| hash.key? username }

      if contributor
        contributor.pull_requests += 9
        contributor.total += 9
      else
        contributors << {
          username.to_sym => {
            pull_requests: 9, comments: 0, reviews: 0, total: 9
          }
        }
      end
    end

    contributors
  end
end
