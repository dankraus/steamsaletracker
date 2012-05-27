class Wishlist < ActiveRecord::Base
	attr_accessible :followed_id

	belongs_to :user_id
	belongs_to :game_id

	validates :user_id, presence: true
	validates :game_id, presence: true
end