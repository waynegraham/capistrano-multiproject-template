# Multiproject Deployment Template

This is a template for managing multiple projects with Capistrano 2.

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

## TODO

- [ ] Section on adding recipes
- [ ] Section on adding stages
- [ ] Section on adding projects
- [ ] Section on adding templates

