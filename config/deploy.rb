# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'bastion'
set :repo_url, 'https://github.com/wata-gh/bastion.git'

set :deploy_to, '/opt'
set :keep_releases, 5
set :linked_dirs, %w{bin log tmp/pids tmp/cache bundle}
set :unicorn_rack_env, fetch(:stage)

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:restart'
    end
  end

  after :publishing, :restart
end
