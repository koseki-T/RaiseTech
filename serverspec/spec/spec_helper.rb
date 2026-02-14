require 'serverspec'
require 'net/ssh'

set :backend, :ssh

#if ENV['ASK_SUDO_PASSWORD']
 # begin
  #  require 'highline/import'
  #rescue LoadError
   # fail "highline is not available. Try installing it."
 # end
 # set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
#else
 # set :sudo_password, ENV['SUDO_PASSWORD']
#end

host = ENV['TARGET_HOST']

# options = Net::SSH::Config.for(host)
options = {}
options[:user] ||= 'ec2-user'

set :host,        options[:host_name] || host 
#上記、SSH config から取れた host_name があればそれを使い、
#なければ環境変数 TARGET_HOST の値を接続先として使う
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
