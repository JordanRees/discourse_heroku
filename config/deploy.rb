set :application, '1net-discourse'
set :deploy_to, "/home/bakis/1net-forum"

set :scm, :git
set :repo_url, 'git@github.com:neo/discourse.git'

set :user, 'bakis'
set :use_sudo, false
set :deploy_via, :copy
set :keep_releases, 5
set :pty, true

set :rbenv_type, :user
set :rbenv_ruby, "2.0.0-p195"

set :default_env, { path: "/home/bakis/.rbenv/shims:/home/bakis/.rbenv/bin:$PATH" }

set :ssh_options, { forward_agent: true, port: 22 }

# Work around bug in capistrano.
# http://blog.blenderbox.com/2013/11/06/precompiling-assets-with-capistrano-3-0-1/
SSHKit.config.command_map[:rake] = "bundle exec rake"

after "deploy", "deploy:cleanup"
after "deploy", "deploy:restart"

namespace :deploy do
  # Tasks to start, stop and restart thin. This takes Discourse's
  # recommendation of changing the RUBY_GC_MALLOC_LIMIT.
  desc 'Start thin servers'
  task :start do
    on roles(:app) do
      run "cd /home/bakis/1net-forum && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml start"
    end
  end

  desc 'Stop thin servers'
  task :stop do
    on roles(:app) do
      run "cd /home/bakis/1net-forum && bundle exec thin -C config/thin.yml stop"
    end
  end

  desc 'Restart thin servers'
  task :restart do
    on roles(:app) do
      run "cd /home/bakis/1net-forum && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml restart"
    end
  end

  # Sets up several shared directories for configuration and thin's sockets,
  # as well as uploading your sensitive configuration files to the serer.
  # The uploaded files are ones I've removed from version control since my
  # project is public. This task also symlinks the nginx configuration so, if
  # you change that, re-run this task.
  task :setup_config do
    on roles(:app) do
      run  "mkdir -p #{shared_path}/config/initializers"
      run  "mkdir -p #{shared_path}/config/environments"
      run  "mkdir -p #{shared_path}/sockets"
      put  File.read("config/database.yml"), "#{shared_path}/config/database.yml"
      put  File.read("config/redis.yml"), "#{shared_path}/config/redis.yml"
      put  File.read("config/environments/production.rb"), "#{shared_path}/config/environments/production.rb"
      put  File.read("config/initializers/secret_token.rb"), "#{shared_path}/config/initializers/secret_token.rb"
      sudo "ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
      puts "Now edit the config files in #{shared_path}."
    end
  end

  # Symlinks all of your uploaded configuration files to where they should be.
  task :symlink_config do
    on roles(:app) do
      run  "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      run  "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
      run  "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
      run  "ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb"
      run  "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    end
  end
end

after "deploy", "deploy:setup_config"
after "deploy", "deploy:symlink_config"

namespace :db do
  desc 'Seed your database for the first time'
  task :seed do
    run "cd #{current_path} && psql -d discourse_production < pg_dumps/production-image.sql"
  end
end

after 'deploy', 'deploy:migrate'
after 'deploy:migrate', 'deploy:start'
