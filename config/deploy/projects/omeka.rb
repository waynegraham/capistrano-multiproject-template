# Project Description
# Primary contact (email address)
# Class name
# Semester
# Any additional notes

set :omeka_admins, {
  'admin1' => {
    :username => "username",
    :display_name => "User's name",
    :email => "user@email.org"
  },
  'admin2' => {
    :username => "username",
    :display_name => "User's name",
    :email => "user@email.org"
  }
}

set :application, "course"

load 'recipes/defaults'
