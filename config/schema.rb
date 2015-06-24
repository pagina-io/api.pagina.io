DB.create_table :users do

  primary_key :id

  column :auth_token, String
  column :ip, String
  column :github_data, :hstore
  column :username, String
  column :avatar_url, String
  column :email, String
  column :github_id, Integer

  column :created_at, DateTime
  column :updated_at, DateTime

end

DB.create_table :repos do

  primary_key :id
  foreign_key :user_id, :users

  column :github_data, :hstore
  column :name, String
  column :description, String
  column :url, String

  column :created_at, DateTime
  column :updated_at, DateTime

end

DB.create_table :repofiles do

  primary_key :id
  foreign_key :repo_id, :repos

  column :filename, String

  column :created_at, DateTime
  column :updated_at, DateTime

end
