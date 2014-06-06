namespace :omeka do

  def git_clone(hash, directory)
    url = ''
    branch = 'master'
    hash.each do |repo_name, repo_info|
      url = repo_info['url']
      branch = repo_info[:branch].nil? ? 'master' : repo_info[:branch]
      run "cd #{current_path}/#{directory} && rm -rf #{repo_name}"
      run "cd #{current_path}/#{directory} && git clone #{url} #{repo_name} --quiet"
      run "cd #{current_path}/#{directory}/#{repo_name} && git fetch --quiet && git checkout #{branch} --quiet" unless branch.to_s.empty?
    end
  end

  def host_and_port
    return roles[:web].servers.first.host, ssh_options[:port] || roles[:web].servers.first.port || 22
  end

  desc "Ensure files directory is wriable"
  task :fix_file_permissions do
    run "chmod -R 777 #{shared_path}/files"
  end

  desc '|OmekaRecipes| Move the files directory out of the way'
  task :move_files do
    run "mv #{current_path}/files #{current_path}/files_deleteme"
  end

  desc "Rename hidden files"
  task :rename_files do
    run "cd #{current_path} && mv .htaccess.changeme .htaccess"
    run "cd #{current_path}/application/config && mv config.ini.changeme config.ini"
  end

  desc "Make backup directory"
  task :make_backup_dir do
    run "mkdir -p #{shared_path}/backups"
  end

  desc '|OmekaRecipes| Link the files directoy for the project'
  task :link_files_dir, :except => {:no_release => true} do
    run "cd #{current_path} && ln -snf #{shared_path}/files"
  end

  desc 'Remove Coins plugin'
  task :remove_files do
    run "rm -rf #{current_path}/plugins/Coins"
    #run "rm -rf #{current_path}/themes/{default,berlin,seasons}"
  end

  desc "Link db.ini"
  task :link_db do
    run "ln -snf #{shared_path}/db.ini #{current_path}/db.ini"
  end

  desc '|OmekaRecipes| Deploy the plugins defined in the plugins hash'
  task :get_plugins do
    git_clone(plugins, 'plugins')
  end

  desc '|OmekaRecipes| Deploy the themes defined in the themes hash'
  task :get_themes do
    git_clone(themes, 'themes')
  end

  after "deploy:cold", "omeka:fix_file_permissions", "omeka:move_files"
  after "deploy", "omeka:get_themes", "omeka:get_plugins", "omeka:link_db", "omeka:rename_files", "omeka:remove_files"
end

