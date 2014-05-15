require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (http://rvm.io)

set :application, 'campo'
set :repo_url, 'git@github.com:railsgirls-cn/campo.git'
set :deploy_to, -> { "/home/ruby/#{fetch(:application)}" }
set :rails_env, 'production'
set :branch, ENV['BRANCH'] || "master"

set :user, 'ruby'
set :domain, 'yafeilee.me'
set :deploy_to, '/home/ruby/campo'
set :repository, 'git@github.com:railsgirls-cn/campo.git'
set :branch, ENV['BRANCH'] || 'master'
set :app_path, "#{deploy_to}/#{current_path}"

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, %w(config/database.yml config/config.yml config/secrets.yml bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads)

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  queue! %[source /usr/local/rvm/scripts/rvm]
  queue! %[rvm use 2.0.0]
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  shared_paths.each do |file_or_dir|
    if file_or_dir[-4..-1] == '.yml'
      # dir
      queue! %[mkdir -p "#{deploy_to}/shared/#{file_or_dir}"]
      queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{file_or_dir}"]
    else
      queue! %[touch "#{deploy_to}/shared/#{file}"]
      queue  %[echo "-----> Be sure to edit 'shared/#{file}'."]
    end
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'unicorn:restart'
      queue! %{
        service resque restart
      }
    end
  end
end

namespace :unicorn do
  set :unicorn_pid, "#{app_path}/tmp/pids/unicorn_campo.pid"
  set :start_unicorn, %{
    cd #{app_path} && bundle exec unicorn -c config/unicorn/#{rails_env}.rb -E #{rails_env} -D
  }
  desc "Start unicorn"
  task :start => :environment do
    queue 'echo "-----> Start Unicorn"'
    queue! start_unicorn
  end

  desc "Stop unicorn"
  task :stop do
    queue 'echo "-----> Stop Unicorn"'
    queue! %{
      mkdir -p "#{app_path}/tmp/pids"
      test -s "#{unicorn_pid}" && kill -QUIT `cat "#{unicorn_pid}"` && rm -rf "#{unicorn_pid}" && echo "Stop Ok" && exit 0
      echo >&2 "Not running"
    }
  end

#                                                                  Restart task
# ------------------------------------------------------------------------------
  desc "Restart unicorn using 'upgrade'"
  task :restart => :environment do
    invoke 'unicorn:stop'
    invoke 'unicorn:start'
  end
end
