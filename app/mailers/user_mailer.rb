class UserMailer < ActionMailer::Base
  default from: "alert@steamsaletracker.com"

  def price_drop_email(user, game)
    @user = user
    @game = game
    @test = "test!"
    mail(:to => user.email, :subject => "Steam Price Drop Alert: #{game.name}")
  end

end
