class Game < ActiveRecord::Base
  has_and_belongs_to_many :wishlists

  attr_accessible :last_price, :name, :price, :price_last_checked_at, :steam_url, :price_last_checked_at
end
