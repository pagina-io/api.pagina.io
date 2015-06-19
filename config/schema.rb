DB.create_table :users do

  primary_key :id

  column :auth_token, String
  column :ip, String
  column :created_at, DateTime
  column :updated_at, DateTime
  column :github_data, :hstore
  column :username, String
  column :avatar_url, String
  column :email, String
  column :github_id, Integer

end

DB.create_table :repos do

  primary_key :id
  foreign_key :user_id, :users

end
