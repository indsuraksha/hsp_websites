set :repository,  "http://svn.hmg.ad.harman.com/repos/hmgwww/trunk/hsp_websites"
set :scm, :subversion
set :deploy_via, :export
set :application, "hsp_websites"
set :deploy_to, "/var/www/hmg/#{application}"

role :web, "10.10.23.86"  # Your HTTP server, Apache/etc
role :app, "10.10.23.86"  # This may be the same as your `Web` server
role :db,  "10.10.23.15", primary: true # This is where Rails migrations will run

set :rails_env, "production"

after "deploy:restart", "deploy:ping"

namespace :deploy do
  desc "Hit the site to really spin it up"
  task :ping, :roles => :web do
    run "wget -nd --delete-after http://10.10.23.87/en-US/"
  end
end

namespace :sphinx do
  task :rebuild do  
    run "cd #{deploy_to}/current; rake RAILS_ENV=#{rails_env} ts:rebuild --rotate"
  end  
end

after "deploy:stop", "delayed_job:stop"
after "deploy:start", "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
