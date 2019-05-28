class ApplicationController < ActionController::Base
  rescue_from Github::Error::NotFound do |error|
    render status: :not_found, json: error.data
  end
end
