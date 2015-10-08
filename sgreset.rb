require 'aws-sdk'
require 'logger'
require './config.rb'

@log = Logger.new File.join(File.dirname(__FILE__), '/log/sgreset.log')

defs = CONFIG[:security_group][:bastion][:defaults]

def reset gid, defs, port
  ec2 = Aws::EC2::Client.new
  pager = ec2.describe_security_groups({
    group_ids: [gid],
  })
  sg = pager.data['security_groups'].select {|sg| sg['group_id'] == gid}.first
  sg['ip_permissions'].select do |ipp|
    ipp['to_port'] == port && ipp['ip_protocol'] == 'tcp'
  end.each do |ipp|
    ipp['ip_ranges'].each do |s|
      ip = s.cidr_ip.split('/')[0]
      next if defs.map{|c| c.split(':')[0] }.include? ip
      @log.info "=> [revoke] #{gid} #{s.cidr_ip} #{port}"
      ec2.revoke_security_group_ingress({
        group_id: gid,
        ip_permissions: [{
          ip_protocol: 'tcp',
          from_port: ipp['from_port'],
          to_port: ipp['to_port'],
          ip_ranges: [s]
        }]
      })
    end
  end
end

@log.info '[start] sgreset.'

@log.info 'reset bastion security group.'
reset CONFIG[:security_group][:bastion][:group_id], defs, 22
@log.info 'reset bastion security group done.'

@log.info 'reset webservice security group.'
reset CONFIG[:security_group][:webservice][:group_id], defs, 80
@log.info 'reset webservice security group done.'

@log.info '[finish] sgreset.'
