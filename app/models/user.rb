class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable #, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :password, :steam_id, :name, :persona_name, :email, :remember_me,
                    :steam_profile_url, :avatar, :avatar_medium, :avatar_full, :country

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}

    #has_and_belongs_to_many :games
    #has_many :games
    has_many :gamewishes
    has_many :games, through: :gamewishes

    

    def self.find_for_steam_id(access_token, signed_in_resource=nil)
        steam_id = access_token["uid"].split("/").last
        user = User.where(steam_id: steam_id).first
    end

    def self.get_steam_user_info(access_token)
        steam_id = access_token["uid"].split("/").last
        steam_api_key = ENV['SteamAPIKey']
        steam_user_profile_uri = URI.parse("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0001/?key=#{steam_api_key}&steamids=#{steam_id}")
        raw_info ||= steam_api_key ? MultiJson.decode(Net::HTTP.get(steam_user_profile_uri)) : {}
        player ||= raw_info["response"]["players"]["player"].first
    end

    def self.new_with_session(params, session)
        super.tap do |user|
        if data = session["devise.steam"] && session["devise.steam"]
            user.steam_id           = data["steamid"]
            user.name               = data["realname"]
            user.persona_name       = data["personaname"]
            user.steam_profile_url  = data["profileurl"]
            user.avatar             = data["avatar"]
            user.avatar_medium      = data["avatarmedium"]
            user.avatar_full        = data["avatarfull"]
            user.country            = data["loccountrycode"]
        end
    end
  end
end

