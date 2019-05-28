Rails.application.routes.draw do
  get 'scoreboard/org/:org', to: 'scoreboard#by_org', as: :scoreboard_by_org
end
