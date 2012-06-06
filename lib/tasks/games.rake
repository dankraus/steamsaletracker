require 'rubygems'
require 'nokogiri'
require 'open-uri'

steam_age_cookie = "Steam_Language=english; browserid=5723971140937457809; lastagecheckage=5-January-1956; store_newreleases_filter_dlc=tab_filtered_dlc_content; steamLogin=76561197972129526%7C%7C52E0B9BA72DD19E5E04953442938A99F04D7EDA0; steamCC_24_216_69_23=US; recentapps=%7B%22209690%22%3A1338251723%2C%2257300%22%3A1338177476%2C%22207610%22%3A1338056988%7D; timezoneOffset=-18000,0"


namespace :games do

	desc "Goes through all Users wishlists to find games. If the game doesn't exist, we add it"
	task :add_from_wishlists => :environment do

		users = User.all
		users.each do |user|
			#recreate the wishlist every time. We do this so it always matches the steam wishlist only.
			user.games = []
			user.save
			
			wishlist_url = user.steam_profile_url + 'wishlist'

			wishlist_doc = Nokogiri::HTML(open("#{wishlist_url}", "Cookie" => steam_age_cookie))
			games = wishlist_doc.css(".wishlistRow")
			
			#games in wishlist
			games.each do |game|
				title = game.css("h4")[0].text
				game_url = game.css(".gameLogo a")[0]['href']
				#if no game exists, add it in.
				game = Game.find_by_steam_url(game_url)
				if !game
					user.games.create(name: title, steam_url: game_url)
				else
					##if the game exists, associate it with our user
					user.games << game
					user.save
				end
			end
		end
	end

	desc "Updates prices on all games"
	task :update_prices => :environment do
		games = Game.all
		games.each do |game|
			game_doc = Nokogiri::HTML(open("#{game.steam_url}", "Cookie" => steam_age_cookie))
			retail_price = game_doc.css(".game_purchase_price").text[/[0-9\.]+/]

			if retail_price
				current_price = retail_price
			else
				#on sale price
				current_price = game_doc.css(".discount_final_price").text[/[0-9\.]+/]	
			end

			game.last_price = game.price
			game.price = current_price
			game.price_last_checked_at = Time.new.to_i

			game.save
		end
	end

	desc "Notify users of games with price decrease"
	task :notify_users => :environment do
		games = Game.where("price_last_checked_at > :time AND price < last_price", time: Time.now - 24.hours.ago)
		#for each game that had a price drop...
		games.each do |game|
			#notify each user who has it in their wishlist
			game.users.each do |user|
				# puts user.email
				# puts "Emailing #{user.email} for #{game.name}"
				UserMailer.price_drop_email(user, game).deliver
			end
		end
	end


end