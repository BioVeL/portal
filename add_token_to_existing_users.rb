users = User.all
users.each do |user|
  user.save
  user.generate_token(:auth_token)
  user.save
end

