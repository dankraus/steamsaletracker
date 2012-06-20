require 'rubygems'
require 'nokogiri'
require 'open-uri'

steam_age_cookie = ""


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
			
			#check to see if we hit an age gate
			if game_doc.css("#agegate_disclaim").text != ""
				#ok, age restriction. Submit the age form with a fake age.
				age_gate_url = game_doc.css("#agegate_box form").attr('action')
				post_res = Net::HTTP.post_form(URI.parse(age_gate_url), { snr: 	  "1_agecheck_agecheck__age-gate",
																		  ageDay:   "1",
																		  ageMonth: "January",
																		  ageYear:  "1987"
				 														} )
				#rebuild the cookie from the age POST
				steam_age_cookie = post_res.to_hash['set-cookie'].collect{|ea|ea[/^.*?;/]}.join
				
				#now that we have the cookie, make the request with the cookie
				game_doc = Nokogiri::HTML(open(game['steam_url'], "Cookie" => steam_age_cookie))
			end	

			if game_doc.css(".game_purchase_price").size > 0

				retail_price = game_doc.css(".game_purchase_price")[0].text[/[0-9\.]+/]

				if retail_price
					current_price = retail_price
				else
					#on sale price
					current_price = game_doc.css(".discount_final_price")[0].text[/[0-9\.]+/]	
				end

				game.last_price = game.price
				game.price = current_price
			end

			game.price_last_checked_at = Time.new

			game.save
		end
	end

	desc "Notify users of games with price decrease"
	task :notify_users => :environment do
		games = Game.where("price < last_price")
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