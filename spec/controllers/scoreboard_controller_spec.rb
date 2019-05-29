require 'rails_helper'
require 'faker'
require './spec/shared'

RSpec.describe ScoreboardController, type: :controller do
  render_views

  include_context "shared"

  it 'returns a list of contributors with point totals for the past week' do
    allow(GithubService).to receive(:repos)           { repos_response }

    allow(GithubService).to receive(:past_week_pulls) do
      pulls_response.select { |pull| pull['number'] == 1348 }
    end

    allow(GithubService).to receive(:reviews)         { reviews_response }
    allow(GithubService).to receive(:comments)        { comments_response }

    expected_body = {
      contributors: [
        { contributor: { pull_requests: 9, total: 9 } },
        { octocat:     { reviews: 3, total: 4, comments: 1 } }
      ],
      winner: 'contributor'
    }.to_json

    get :by_org, params: { org: github_org }

    assert_response 200
    expect(response.body).to eq expected_body
  end
end
