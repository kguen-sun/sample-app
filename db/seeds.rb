User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n + 1}@railstutorial.org"
  password = "password"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now
  )
end

users = User.order(:created_at).take 6
50.times do |n|
  content = Faker::Lorem.sentence word_count: 5
  users.each do |user|
    user.microposts.create! content: content
  end
end

user = User.first
users = User.all
following = users[2..50]
followers = users[3..40]
following.each do |followed|
  user.follow followed
end
followers.each do |follower|
  follower.follow user
end
