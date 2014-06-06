set :repository,  "git://github.com/omeka/Omeka.git"
set :scm, :git
set :branch, "stable-2.1"

set :project_roles, %w(app db web)

set :deploy_to, "/usr/local/projects/#{application}"

default_run_options[:pty] = true
#set :user, 'sds-deployer'
set :deploy_via, :remote_cache
set :runner, :user
set :run_method, :run

set :keep_releases, 3

set :plugins, {
  'Neatline'          => { 'url' => 'git://github.com/scholarslab/Neatline.git', :branch => 'master' },
  'SimplePages'       => { 'url' => 'https://github.com/omeka/plugin-SimplePages.git', :branch => 'tags/v2.0.1' },
  'ExhibitBuilder'    => { 'url' => 'https://github.com/omeka/plugin-ExhibitBuilder.git', :branch => 'tags/v2.0.3' },
  'NeatlineSimile'    => { 'url' => 'https://github.com/scholarslab/nl-widget-Simile.git', :branch => 'master' },
  'NeatlineWaypoints' => { 'url' => 'https://github.com/scholarslab/nl-widget-Waypoints.git', :branch => 'master' },
  'BulkUsers'         => { 'url' => 'https://github.com/clioweb/BulkUsers.git', :branch => 'master' },
  'NeatlineText'      => { 'url' => 'https://github.com/scholarslab/nl-widget-Text.git', :branch => 'master' }
}

set :themes, {
  'default'   => { 'url' => 'https://github.com/omeka/theme-thanksroy.git', :branch => "tags/v2.0.3" },
  'berlin'    => { 'url' => 'https://github.com/omeka/theme-berlin.git', :branch => "tags/v2.1" },
  'seasons'   => { 'url' => 'https://github.com/omeka/theme-seasons.git', :branch => "tags/v2.1.2" },
  'neatlight' => { 'url' => 'https://github.com/davidmcclure/neatlight.git', :branch => 'master' },
  'astrolabe' => { 'url' => 'https://github.com/scholarslab/astrolabe.git', :branch => 'master' },
  'neatscape' => { 'url' => 'https://github.com/scholarslab/neatscape.git', :branch => 'master' }
}

set :omeka_defaults, {
   'email'    => 'scholarslab@virginia.edu',
   'username' => 'admin',
   'password' => 'admin_password'
}

after "deploy:cold", "db:mysql:setup", "db:create_ini", "deploy"
after "deploy", "deploy:cleanup"
