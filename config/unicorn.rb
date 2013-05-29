worker_processes 10

working_directory "/var/www/zientia/current" # available in 0.94.0+

listen 5002, :tcp_nopush => true

timeout 30

pid "/var/www/zientia/shared/pids/unicorn.pid"

stderr_path "/var/www/zientia/shared/log/unicorn.stderr.log"
stdout_path "/var/www/zientia/shared/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true


before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end