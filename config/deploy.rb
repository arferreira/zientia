require 'bundler/capistrano'

 
# Quando trabalhando com o rbenv deve se copiar o $PATH do linux
# para execuções do bundle e binarios do ruby
# <required>
set :default_environment, {
  'PATH' => "/opt/local/bin:/opt/local/sbin:/opt/local/ruby/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
}

set :application, 'www.zientiaeducacional.com.br'

set :keep_releases, 3

set :scm, :git

set :repository, 'git://github.com/arferreira/zientia.git'

set :branch, 'master'

set :deploy_via, :remote_cache

set :user, "root"

set :use_sudo, false

set :deploy_to, '/var/www/zientia'

set :current, "#{deploy_to}/current"

role :web, application
role :app, application
role :db,  application, primary: true


 
# Minhas configurações do Unicorn
# comando para execução do unicorn
# <optinal>
set :unicorn_binary,  "bundle exec unicorn"
# caminho para o arquivo de configuração do unicorn
# <optinal>
set :unicorn_config,  "#{current_path}/config/unicorn.rb"
# onde será armazenado o pid do processo do unicorn
# <optinal>
set :unicorn_pid,     "#{current_path}/tmp/pids/unicorn.pid"


# executar antes do 'deploy:update_code' o comando 'deploy.check_folders'
# do capistrano
before 'deploy:update_code' do
  deploy.check_folders
end

namespace :deploy do
  # task :start do
#     %w(config/database.yml).each do |path|
#       from  = "#{deploy_to}/#{path}"
#       to    = "#{current}/#{path}"
# # 
#       run "if [ -f '#{to}' ]; then rm '#{to}'; fi; ln -s #{from} #{to}"
#     end
  #   run "cd #{current} && RAILS_ENV=production && GEM_HOME=/opt/local/ruby/gems && bundle exec unicorn_rails -c #{deploy_to}/config/unicorn.rb -D"

  # end

  # task :stop do
    
  #   run "if [ -e /var/www/cupom/shared/pids/unicorn.pid ]; then kill `cat /var/www/cupom/shared/pids/unicorn.pid`; fi;"
  # end

  # task :restart do
  #   stop
  #   start
  # end

  ## News methods ->

  #starta a aplicação com o unicorn
  desc "Start Application"
  task :start, :roles => :app, :except => { :no_release => true } do 
    # comando bash, navega ate a pasta da versao atual, e executa o unicorn
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config}" <<
        " -E #{rails_env} -D"
  end
  
  # mata o serviço do unicorn
  desc "Stop Application"
  task :stop, :roles => :app, :except => { :no_release => true } do 
    # mata o serviço do unicorn passando o pid definido na linha 99
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  
  # mata o serviço do unicorn apos axecuções atual
  desc "Graceful Stop Application"
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  
  # reinicia o serviço do unicorn
  task :restart, :roles => :app, :except => { :no_release => true } do
    # para o serviço
    stop
    # starta o serviço
    start
  end

  # verifica as pasta necessarias para o envio, e inicialização do s serviços
  # para corrigir bug que aconteceu comigo, talvez ja tenham corrigido esse erro
  desc "Creating folders necessary"
  task :check_folders do
    run "if [ ! -d '#{deploy_to}' ];then mkdir #{deploy_to}; fi"
    run "if [ ! -d '#{deploy_to}/#{version_dir}' ];then mkdir #{deploy_to}/#{version_dir}; fi"
    run "if [ ! -d '#{deploy_to}/#{shared_dir}' ];then mkdir #{deploy_to}/#{shared_dir}; fi"
    run "if [ ! -d '#{deploy_to}/#{shared_dir}/pids' ];then mkdir #{deploy_to}/#{shared_dir}/pids; fi"
    run "if [ ! -d '#{deploy_to}/#{shared_dir}/log' ];then mkdir #{deploy_to}/#{shared_dir}/log; fi"
  end
end

namespace :ruby do
  desc "Show ruby version"
  task :version do
    run "cd #{current_release} && ruby -v"
  end
  desc "List process (sla) on server"
  task :list do
    run "top"
  end
end

namespace :unicorn do
  desc "Show error log"
  task :error_log, :except => { :no_release => true } do
    run "cat #{deploy_to}/#{shared_dir}/log/unicorn.stderr.log"
  end

  desc "Show out log"
  task :out_log, :except => { :no_release => true } do
    run "cat #{deploy_to}/#{shared_dir}/log/unicorn.stdout.log"
  end
end

