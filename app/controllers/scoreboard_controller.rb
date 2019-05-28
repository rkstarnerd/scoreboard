class ScoreboardController < ApplicationController
  def by_org
    org          = params[:org]
    repos        = GithubService.repos(org)

    if repos.empty?
      render status: :ok, json: {
        message: 'There have been no recent contributions to this org'
      }
    else
      pulls        = org_pull_requests(org, repos)
      reviews      = org_reviews(org, pulls)
      comments     = org_comments(org, pulls)

      @contributors = org_contributors(pulls, reviews, comments)

      render template: 'scoreboard/by_org.json.jbuilder'
    end
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
      username = pull['user']['login'].to_sym
      contributor = contributors.find { |hash| hash.key? username }

      if contributor
        contributor.values[0][:pull_requests] += 9
        contributor.values[0][:total] += 9
      else
        contributors << {
          username => {
            pull_requests: 9, comments: 0, reviews: 0, total: 9
          }
        }
      end
    end

    reviews.each do |review|
      username = review['user']['login'].to_sym
      contributor = contributors.find { |hash| hash.key? username }

      if contributor
        contributor.values[0][:reviews] += 3
        contributor.values[0][:total] += 3
      else
        contributors << {
          username => {
            pull_requests: 0, comments: 0, reviews: 3, total: 3
          }
        }
      end
    end

    comments.each do |comment|
      username = comment['user']['login'].to_sym
      contributor = contributors.find { |hash| hash.key? username }

      if contributor
        contributor.values[0][:comments] += 1
        contributor.values[0][:total] += 1
      else
        contributors << {
          username => {
            pull_requests: 0, comments: 1, reviews: 0, total: 1
          }
        }
      end
    end

    contributors
  end
end
