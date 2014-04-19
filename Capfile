require 'capistrano/ext/multistage'
require 'capistrano/node-deploy'

set :stages, %w(acceptance production1 production2)
set :default_stage, 'acceptance'

set :application, 'boardroom'
set :repository,  'git://github.com/carbonfive/boardroom'
set :user, 'deploy'
set :scm, :git

role :app, 'stickies.io'
