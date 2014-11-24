require 'sinatra'
require 'aws-sdk'
require './config.rb'

get '/' do
  erb :index
end

post '/' do
  ec2 = Aws::EC2::Client.new
  begin
    gid = CONFIG[:security_group][:platform][:group_id]
    res = ec2.authorize_security_group_ingress({
      dry_run: false,
      group_id: gid,
      ip_permissions: [{
        ip_protocol: 'tcp',
        from_port: 22,
        to_port: 22,
        ip_ranges: [{
          cidr_ip: "#{request.ip}/32"
        }]
      }]
    })
    if res.successful?
      @msg = '登録完了しました。'
    else
      @msg = '登録に失敗しました。'
    end
  rescue => e
    @msg = e.message
  end
  erb :result
end
