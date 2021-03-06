dir = '/var/apps/boardroom/production1'
secrets = %w(TWITTER_SECRET GOOGLE_CLIENT_SECRET FACEBOOK_APP_SECRET).map { |s| "#{s}=$(cat #{dir}/config/#{s})"}.join ' '

set :branch, 'master'
set :deploy_to, dir
set :node_env, 'production'
set :upstart_job_name, 'boardroom-production1'
set :app_environment, "CPUS=2 PORT=1337 #{secrets}"
