require 'rails_helper'
require './spec/shared'

RSpec.describe GithubService do
  include_context "shared"

  let(:repo_name)   { repos_response.first['name'] }
  let(:pull_number) { pulls_response.first['number'] }

  it 'gets a list of github repos for an org' do
    allow_any_instance_of(Github::Client)
      .to receive_message_chain('repos.all') { repos_response }

    github_repos = JSON.parse(GithubService.repos(org).to_json)

    expect(github_repos).to eq repos_response
    expect(github_repos.count).to eq 1
  end

  it 'gets the pull requests for a github repo' do
    allow_any_instance_of(Github::Client)
      .to receive_message_chain('pull_requests.all') { pulls_response }

    pulls = GithubService.pulls(org, repo_name)

    expect(pulls.count).to eq 2
    expect(pulls).to eq pulls_response
  end

  it 'gets the pull requests since a particular date' do
    allow_any_instance_of(Github::Client)
      .to receive_message_chain('pull_requests.all') { pulls_response }

    pulls = GithubService.pulls_since(Time.new(2011, 1, 1), org, repo_name)

    expect(pulls.count).to eq 2

    pulls = GithubService.pulls_since(Time.new(2019, 1, 1), org, repo_name)

    expect(pulls.count).to eq 1

    pulls = GithubService.past_week_pulls(org, repo_name)

    expect(pulls.count).to eq 1
  end

  it 'gets the comments on a pull request' do
    allow_any_instance_of(Github::Client)
      .to receive_message_chain('pull_requests.comments.list') { comments_response }

    comments = GithubService.comments(org, repo_name, pull_number)

    expect(comments.count).to eq 1
    expect(comments).to eq comments_response
  end

  it 'gets the reviews on a pull request' do
    allow_any_instance_of(Github::Client)
      .to receive_message_chain('pull_requests.reviews.list') { reviews_response }

    reviews = GithubService.reviews(org, repo_name, pull_number)

    expect(reviews.count).to eq 1
    expect(reviews).to eq reviews_response
  end
end
