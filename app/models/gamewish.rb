class Gamewish < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  attr_accessible :game_id, :user_id
end
