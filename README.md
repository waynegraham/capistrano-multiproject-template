# Multiproject Deployment Template

This is a template for managing multiple projects with Capistrano 2. 

## Installation

[Fork this repository](https://help.github.com/articles/fork-a-repo) and
clone it to you computer. On your local computer, run the `bundle install`
command (you'll need to have Ruby installed on your local computer). 

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

