class Game < ActiveRecord::Base
  has_many :gamewishes
  has_many :users, through: :gamewishes

  attr_accessible :last_price, :name, :price, :price_last_checked_at, :steam_url, :price_last_checked_at
end
