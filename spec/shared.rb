# Test helper methods

RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "shared", shared_context: :metadata do
  let(:org) { github_org }

  let(:repos_response) do
    JSON.parse(file_fixture('org_repos_response.json').read)
  end

  let(:pulls_response) do
    JSON.parse(file_fixture('repo_pulls_response.json').read)
  end

  let(:comments_response) do
    JSON.parse(file_fixture('pulls_comments_response.json').read)
  end

  let(:reviews_response) do
    JSON.parse(file_fixture('pulls_reviews_response.json').read)
  end

  def github_org
    Faker::Company.name.downcase.gsub(/[^a-zA-Z]+/, '-')
  end
end
