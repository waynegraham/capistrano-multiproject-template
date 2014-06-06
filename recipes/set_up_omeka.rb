require 'mechanize'

namespace :omeka do

  def uri
    @uri ||= "http://#{application}.#{server}"
  end

  def install_form

    puts "Setting up the Omeka installation..."
    agent = Mechanize.new

    uri
    agent.get "#{@uri}/install/"
    form = agent.page.forms.first

    form['username'] = omeka_defaults['username']
    form['password'] = omeka_defaults['password']
    form['password_confirm'] = omeka_defaults['password']
    form['super_email'] = omeka_defaults['email']
    form['administrator_email'] = omeka_defaults['email']
    form['site_title'] = application

    button = form.button_with(:value => 'Install')
    agent.submit(form, button)

  end

  def enable_omeka_plugins
    puts "Enabling plugins..."

    agent = Mechanize.new
    uri

    agent.get "#{@uri}/admin/" do |page|
      admin_page = page.form_with(:action => "/admin/users/login") do |form|
        form['username'] = omeka_defaults['username']
        form['password'] = omeka_defaults['password']
      end.submit

      plugins_page = agent.click(admin_page.link_with(:text => %r/Plugins/))

      puts plugins_page.forms
    end
  end

  def add_users
    puts "Adding users..."

    agent = Mechanize.new

    uri
    agent.get "#@{uri}/admin/" do |page|
      admin_page = page.form_with(:action => "/admin/users/login") do |form|
        form['username'] = omeka_defaults['username']
        form['password'] = omeka_defaults['password']
      end.submit

      user_page = agent.click(admin_page.link_with(:text => %r/Users/))
      add_user_page = agent.click(user_page.link_with(:text => %r/Add a User/))
      user_form = add_user_page.forms.last


      omeka_users.each do |key, info|
        puts "Adding #{key} to the user tables..."
        user_form.username = info[:username]
        user_form['name'] = info[:display_name]
        user_form.email = info[:email]

        button = user_form.button_with(:value => "Add User")

        agent.submit(user_form, button)

      end

    end

    @uri

  end

  desc 'setup new site'
  task :set_up_site do
    install_form
    add_users
  end

  desc "Add users"
  task :add_omeka_users do
    add_users
  end

  desc "enable plugins"
  task :enable_plugins do
    enable_omeka_plugins
  end

end

