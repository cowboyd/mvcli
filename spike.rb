# mach

# resources :users
match 'users :id' 'users#show'
match 'users create' 'users#create'
match 'create user '
match 'list user :id'

match 'show user cowboyd@thefrontside.net'

collection :users
# create user
# mach users:create --email blah
# mach users #=> shows a list of users, with built in pagination
# mach users cowboyd
collection :
