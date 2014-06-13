# Multiproject Deployment Template

This is a template for managing multiple projects with [Capistrano 2](https://github.com/capistrano/capistrano/wiki).

## Installation

You will need to have [Ruby](https://www.ruby-lang.org) and [Bundler](http://bundler.io/)
installed on your computer. If you're on OS X, I highly recommend
[RVM](http://rvm.io/).

1. [Fork this repository](https://help.github.com/articles/fork-a-repo).
2. [Clone the fork](https://help.github.com/articles/fork-a-repo#step-2-clone-your-fork) to your computer.
3. Change to the directory you cloned the repository to on your local
   machine.
4. On your local machine, run the `bundle install`.

```shell
$ mkdir -p ~/projects
$ cd projects
$ git clone https://github.com/waynegraham/capistrano-multiproject-template.git omeka_deployments
$ cd omeka_deployments
$ bundle install
```

## Configuration

This approach separates **projects** (e.g. instances of Omeka) and
**stages** (servers to deploy to). The configurations are in the
`config/deploy/` directory.


### Stages

Files here define server spaces to deploy to. You may very well have
only one "production" stage to deploy to, but this configuration allows
you to deploy to "staging" and other testing environments you need to
deploy a project.

#### Examples

Each file has server configuration options for each stage, but most
importantly tells capistrano what server to log in to to deploy the
code.

```ruby
# config/deploy/stages/production.rb

server 'your-server.edu', :app, :web, :db, :primary => true

set :user, 'user-that-can-write-to-server-destination'

set :db_host, 'your-database-server'

set :stage_suffix, 'domain-suffix.edu'

# recipes for this stage
load 'recipes/db'
```
### Projects

Files here define the application name (e.g. subdomain) and a special
hash of users to pre-populate the site with.

#### Example

```ruby
# config/deploy/stages/el2000.rb
#
# Instructor: Thomas Jefferson (tjeff@virginia.edu)
#
# Fall 2014
#
# Enlightenment Thinking (el2000)

set :omeka_users, {
  'instructor' = {
    :username     => "tjeff",
    :display_name => "Thomas Jefferson",
    :email        => "tjeff@virginia.edu"
  },
  'ta1' = {
    :username     => "jmadison",
    :display_name => "James Madison",
    :email        => "j.madison@virginia.edu"
  },
  'ta2' = {
    :username     => "jmonroe",
    :display_name => "James Monroe",
    :email        => "j.monroe@virginia.edu"
  }
}

set :application, "el2000"
load "recipes/omeka_neatline"
```

### Recipes

Recipes allow you to create specific functionality for your server
environment. In the case of the Neatline deployment, we set some
specific defaults in the `omeka_defaults` recipe (including the default
plugins to deploy). Including in this file are some default plugins and
themes (as well as default usernames and passwords for the admin user in
Omeka).

```ruby
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
```

As the plugins/themes are updated, you can change the branch you are
using. To add new themes, simply give the theme/plugin a name and point
the `url` at the appropriate git repository.

**Note** Use the `https` version of the git repository, not the SSL as
you will be propted for login credentials.

### Templates
Templates allow you to automate things like writing your vhost configs.
Templates use [ERB](http://apidock.com/ruby/ERB).

```ruby
<VirtualHost *:80>

  DocumentRoot <%= current_path %>

  ServerName <%= server_name %>

  ErrorLog logs/<%= application %>_error.log
  CustomLog logs/<%= application %>_access.log common

  DocumentRoot <%= current_path %>

  <Directory <%= current_path %>
    Options FollowSymlinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>

</VirtualHost>
```

## Apache
Capistrano has a particular structure it uses to deploy projects. You
will need to update your Apache/HTTPD config to set the `DocumentRoot`
to the `current` directory. This is an example of an Apache vhost file:

```
<VirtualHost *:80>

  DocumentRoot /usr/local/projects/el2000/current

  ServerName el2000.neatline-uva.org

  ErrorLog logs/el2000_error.log
  CustomLog logs/el2000_access.log common

  DocumentRoot /usr/local/projects/el2000/current

  <Directory /usr/local/projects/el2000/current>
    Options FollowSymlinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>

</VirtualHost>
```

## Usage

The pattern is to use `cap stage project task` to deploy projects. There
is a helper for each command, however, to remind you what commands you
can type:

* `cap ?` lists defined stages
* `cap stage ?` lists defined projects for a given stage
* `cap stage project ?` lists tasks defined for a project
* `cap stage project task` executed the capistrano task for a project in
  the context of the stage

### Server Setup

Capistrano uses the `:deploy_to` symbol to store where to put the
directories on the server. The default (in `recipes/omeka_defaults.rb`)
is set to `/usr/local/projects/#{application}`. When you run the `cap
stage project deploy:setup` command, capistrano will log on to your
server and create the directory structure for you. Say your
**production** stage has the project **el2000**, capistrano would create
the following directories in `/usr/local/projects/el2000/`:

```
.
|____releases
|____shared
| |____system
| |____log
| |____pids
```

When you run the `cap deploy` task, this will place a timestamped
checkout of Omeka in the `releases` directory, and create a symlink in
the project directory (`/usr/local/projects/el2000`) named `current`.
The resulting top-level directory tree looks like this:

```
.
|____current -> /usr/local/projects/el2000/releases/20140613210651
|____releases
|____shared
```

The `shared` directory is also where the `files` directory and the
`db.ini` file should be saved. The `deploy` task will create symlinks
for these, and it ensures that the files are available between
deployments.

#### SSL
So you're not prompted for your password, you can use SSH keys with your
server. If you don't have a public key generated, you can create on with
the `ssh-keygen` command.

```shell
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/user/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/user/.ssh/id_rsa.
Your public key has been saved in /Users/user/.ssh/id_rsa.pub.
The key fingerprint is:
8c:6a:0d:1c:ac:20:a6:3b:24:9d:6f:9c:e2:fb:19:43 user@computer
The key's randomart image is:
+--[ RSA 2048]----+
|*+..             |
|++o+             |
|.  o+.           |
|  ..E. o         |
| . +o . S        |
|  . o+           |
|   .oo.          |
|  ...            |
|   ...           |
+-----------------+
```

Once you've generate the keys, you can copy the public key to the server.

```shell
$ scp .ssh/id_rsa.pub user@server:~/
```

Then log on to the server and add the key to the
`~/.ssh/authorized_keys` files:

```shell
$ ssh user@server
server$ cat id_rsa.pub >> .ssh/authorized_keys
```

You should now be able to log on the remote server without needing to
type you credentials as your private key on your computer authenticates
with the public key on the server.

### Creating a New Instance

To create a new Omeka instance, simply create a new file in
`config/deploy/projects` (see above). Once this file is created, you can
deploy it to a given **stage**.

```shell
$ cap ?
staging            # Load stage staging configuration
production         # Load stage production configuration

$ cap staging ?
el2000             # Load project el2000 configuration

$ cap staging el2000 ?

$ cap staging el2000 deploy:setup
```

At this point, you will see a bunch of console logging messages go by
logging what capistrano is doing.

After the initial project setup, you can deploy all of the plugins:

```shell
$ cap staging el2000 deploy
```

Once this is fully deployed, you can run the `omeka:setup` task to
fill out the Omeka installation page, as well as add any users defined
in the file.

Once finished (and if you've included the `notices` recipes),
[Strongbad](http://www.homestarrunner.com/sbemail.html) will let you
know that the project has been "deployinated".

```
  el2000 Deployinated
           \
             ____
          .-'    '-.
         /.|      | \
        // :-.--.-:`\|
        ||| `.\/.' |||
        || `-'\/'-' ||
   .--. ||  .'  '.  || .--.
  /   .: \/ .--. \// :.    \
 |  .'  | \  '--'  / |  `.  |
  \ '-'/'. `-.__.-' .'\`-' /
   '--: /\  _|  |_  /\ :--'
       `\ '/      \' /'
         '.        .'
          :.______.:
          '.      .'
           : .--. :
           | |  | |
           L_|  |_J
          J  |  |  L
         /___|  |___\
```

### Updating everything
You can update themes and plugins for individual projects with the
`omeka:update_themes` and `omeka:update_plugins` tasks. This does not do
a full deployment of Omeka, only retrieving the latest version of the
plugins. However, if you have a lot of projects, this is a pain. There
is a script in the `bin` directory that will allows you to perform a
**task** on all **projects** in a given **stage**.

Say a new version of Omeka is released, simply run this command to
update all projects on your "production" stage.

```shell
$ ./bin/deploy update production
```

For usage docs, just execute the script

```shell
$ ./bin/deploy
Commands:
  deploy help [COMMAND]       # Describe available commands or one specific command
  deploy update STAGE [TASK]  # Runs a [TASK] for all projects to a particular STAGE. Defaults to 'deploy' task.
```

# Licence
See [LICENCSE](LICENSE) file.

# Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Get lists on the list of [contributors](https://github.com/waynegraham/capistrano-multiproject-template/graphs/contributors).

