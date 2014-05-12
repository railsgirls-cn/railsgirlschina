# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'campo'
set :repo_url, 'git@github.com:railsgirls-cn/campo.git'
set :deploy_to, -> { "/home/ruby/#{fetch(:application)}" }
set :rails_env, 'production'
set :branch, ENV['BRANCH'] || "master"

set :linked_files, %w{config/database.yml config/config.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads}

namespace :deploy do
  desc "Restart unicorn and resque"
  task :restart do
    invoke 'unicorn:restart'
    invoke 'deploy:resque:restart'
  end
  after :publishing, :restart

  namespace :unicorn do
    desc "restart unicorn"
    task :restart do
      on roles(:app) do
        run "cd #{current_path} && unicorn -c config/unicorn/production.rb -E production -D"
      end
    end
  end

  namespace :resque do
    %w( start stop restart ).each do |action|
      desc "#{action} resque worker"
      task action do
        on roles(:app) do
          execute :service, :resque, action
        end
      end
    end
  end
end
