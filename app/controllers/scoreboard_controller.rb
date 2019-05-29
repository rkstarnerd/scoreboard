class ScoreboardController < ApplicationController
  SCOREBOARD_POINTS = { pull_requests: 9, reviews: 3, comments: 1 }.freeze

  def by_org
    org   = params[:org]
    repos = GithubService.repos(org)

    if repos.empty?
      render status: :ok, json: {
        message: 'There have been no recent contributions to this org'
      }
    else
      pulls    = org_pull_requests(org, repos)
      reviews  = org_reviews(org, pulls)
      comments = org_comments(org, pulls)

      @contributors = org_contributors(pulls, reviews, comments)
      @winner = (@contributors.max_by { |hash| hash.values[0][:total] }).keys
                                                                        .join

      render template: 'scoreboard/by_org.json.jbuilder'
    end
  end

  private

  def org_pull_requests(org, repos)
    repos.each.each_with_object([]) do |repo, pull_requests|
      pull_requests << GithubService.past_week_pulls(org, repo['name'])
    end.flatten
  end

  GithubService::PULL_REQUEST_METHODS.each do |method|
    define_method("org_#{method}") do |org, pulls|
      pulls.each_with_object([]) do |pull, contributions|
        contributions << GithubService.send(method.to_sym, org,
                                            pull['head']['repo']['name'],
                                            pull['number'].to_i)
      end.flatten
    end
  end

  def org_contributors(pulls, reviews, comments)
    contributors = []

    [{ pull_requests: pulls },
     { reviews: reviews },
     { comments: comments }].each do |contribution|
       calculate_points(contribution, contributors)
     end

    contributors
  end

  def username(contribution)
    contribution['user']['login'].to_sym
  end

  def contributor(contributors, username)
    contributors.find { |hash| hash.key? username }
  end

  def calculate_points(contributions, contributors = [])
    type = contributions.keys[0]
    list = contributions[type]

    list.each do |item|
      username = username(item)
      contributor = contributor(contributors, username)

      if contributor
        add_points(contributor, type)
      else
        add_contributor(contributors, username, type)
      end
    end
  end

  def add_points(contributor, type)
    contributions = contributor.values[0]
    points = SCOREBOARD_POINTS[type]

    (contributions[type] && contributions[type] += points) ||
      contributions[type] = points
    (contributions[:total] && contributions[:total] += points) ||
      contributions[:total] = points
  end

  def add_contributor(contributors, username, type)
    points = SCOREBOARD_POINTS[type]
    contributors << { username => { type => points, total: points } }
  end
end
