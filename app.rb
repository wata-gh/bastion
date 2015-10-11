require 'sinatra'
require 'sinatra/config_file'
require 'aws-sdk'
require 'logger'
require 'active_record'
require './models/user'

config_file 'config.yml'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(settings.environment)
ActiveRecord::Base.default_timezone = :local

Aws.config = settings.aws_config

get '/' do
  erb :index
end

def auth_sec_group ec2, gid, port
  ec2.authorize_security_group_ingress({
    dry_run: false,
    group_id: gid,
    ip_permissions: [{
      ip_protocol: 'tcp',
      from_port: port,
      to_port: port,
      ip_ranges: [{
        cidr_ip: "#{request.ip}/32"
      }]
    }]
  })
end

post '/' do
  ec2 = Aws::EC2::Client.new
  gid = settings.security_group[:bastion][:group_id]
  begin
    res = auth_sec_group ec2, gid, 22
  rescue Aws::EC2::Errors::InvalidPermissionDuplicate
    logger.info "already registered. #{gid}:22 #{request.ip}"
  end
  gid = settings.security_group[:webservice][:group_id]
  begin
    res = auth_sec_group ec2, gid, 80
  rescue Aws::EC2::Errors::InvalidPermissionDuplicate
    logger.info "already registered. #{gid}:80 #{request.ip}"
  end
  if res != nil && res.successful?
    @msg = '登録完了しました。'
  else
    @msg = '登録に失敗しました。'
  end
  erb :result
end

get '/users/' do
  @users = User.all
  erb :users
end

post '/users/' do
  content_type 'application/json; chartset=utf8'
  pass = [*1..9, *'A'..'Z', *'a'..'z'].sample(8).join
  u = User.new params[:user]
  system "ccert/cert #{u.name} #{u.email} #{pass}"
  if u.save
    {:is_success => 1}.to_json
  else
    {:is_success => 0, :errors => u.errors}.to_json
  end
end
