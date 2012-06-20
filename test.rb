require 'rubygems'
require 'nokogiri'
require 'open-uri'

steam_age_cookie = ""
game = { "steam_url" => "http://store.steampowered.com/app/207080/" }


game_doc = Nokogiri::HTML(open(game['steam_url'], "Cookie" => steam_age_cookie))
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

puts game_doc.css(".game_purchase_price")[0].text