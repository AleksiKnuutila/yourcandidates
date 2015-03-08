class UserMailer < ApplicationMailer
  default from: "mail@yourcandidates.org.uk"

  def welcome_email(email)
    mail(to: email, subject: 'test')
  end
end
