require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domains, %w[vm1.local vm2.local]
# set :domains, %w[vm1.local]
# set :domains, %w[vm2.local]
set :deploy_to, '/home/vagrant/test'
set :repository, 'https://github.com/masiuchi/mina-sample'
set :branch, 'master'

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

set :user, 'vagrant'

# They will be linked in the 'deploy:link_shared_paths' step.
# set :shared_dirs, fetch(:shared_dirs, []).push('config')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

set :shared_dirs, fetch(:shared_dirs, []).push('pids')
set :shared_paths, ['pids']

pwd = Dir.pwd

# This task is the environment that is loaded all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

desc "setup to all servers"
task :setup_all do
  isolate do
    domains.each do |domain|
      puts "SETUP:DOMAIN:"+domain
      set :domain, domain
      if domain.match(/vm1/)
        set :identity_file, "#{pwd}/.vagrant/machines/vm1/virtualbox/private_key"
      else
        set :identity_file, "#{pwd}/.vagrant/machines/vm2/virtualbox/private_key"
      end
      invoke :setup
      run!
    end
  end
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    # invoke :'bundle:install'
    # invoke :'rails:db_migrate'
    # invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    invoke :test
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run :local { say 'done' }
end

task :test do
  queue %[
    if [ $HOSTNAME = "vm1" ]; then
      echo vm1.local
    else
      echo vm2.local
    fi
  ]
end

desc "Deploy to all servers"
task :deploy_all do
  Dir::glob("app/**/*.rb").each {|f|
    if File.read(f).include?("binding.pry")
      puts "binding.pry is found. ===> #{f}  deploy?  (y/n)"
      input = STDIN.gets
      if input.include?("n")
        exit 1
      end
    end
  }
  puts "BRANCH:"+branch
  isolate do
    domains.each do |domain|
      set :domain, domain
      if domain.match(/vm1/)
        set :identity_file, "#{pwd}/.vagrant/machines/vm1/virtualbox/private_key"
      else
        set :identity_file, "#{pwd}/.vagrant/machines/vm2/virtualbox/private_key"
      end
      puts "DOMAIN:"+domain
      invoke :deploy
      run!
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/docs
