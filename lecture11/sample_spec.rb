require 'spec_helper'

listen_port = 80

#==========================#
# puma.sockが存在しているか#
#==========================#

describe file('/home/ec2-user/raisetech-live8-sample-app/tmp/sockets/puma.sock') do 
  it {should be_socket}
end

#==========================#
# Nginxがインストール済みか#
#==========================#

describe package('nginx') do
  it { should be_installed }
end

#====================#
# Nginxが動いているか#
#====================#

describe service('nginx') do
  it { should be_running }
end

#===================#
# pumaが動いているか#
#===================#

describe service('puma.service') do
  it { should be_running }
end

#===================#
# portが開いているか# 
#===================#

describe port(listen_port) do
  it { should be_listening }
end

#============#
# 200を返すか#
#============#

describe command("curl http://127.0.0.1:#{listen_port}/ -o /dev/null -w \"%{http_code}\n\" -s") do
  its(:stdout) { should match /^200$/ }
end

#===============================#
# rubyは確認できるか（絶対パス）# 
#===============================#

#describe command('/home/ec2-user/.rbenv/shims/ruby -v') do
  #its(:stdout) { should match /3\.2\.3/ }
  #its(:exit_status) { should eq 0 }
#end

#=================================#
# rubyは確認できるか（Sudo無効化）#
#=================================#

describe command('ruby -v') do
  let(:disable_sudo) { true } #Sudo無効化
  its(:stdout) { should match /3\.2\.3/ }
  its(:exit_status) { should eq 0 }
end


