workers Integer(ENV['PUMA_WORKERS'] || 2)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

# daemonize true

rackup      DefaultRackup
port        ENV['PORT']     || 9292
environment ENV['RACK_ENV'] || 'development'

# stdout_redirect "#{ENV['APP_ROOT']}/log/puma.stdout.log", "#{ENV['APP_ROOT']}/log/puma.stderr.log", true

if ENV['RACK_ENV'] == 'production'
  pidfile "#{ENV['APP_ROOT']}/tmp/puma.pid"
  state_path "#{ENV['APP_ROOT']}/tmp/puma.state"
  bind "unix://#{ENV['APP_ROOT']}/tmp/puma.sock"
end

on_worker_boot do
  #DB.disconnect
end
