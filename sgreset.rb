require 'aws-sdk'
require './config.rb'

gid = CONFIG[:security_group][:platform][:group_id]
ec2 = Aws::EC2::Client.new
pager = ec2.describe_security_groups({
  group_ids: [gid],
})
sg = pager.data['security_groups'].select {|sg| sg['group_id'] == gid}.first
sg['ip_permissions'].select do |ipp|
  ipp['to_port'] == 22 && ipp['ip_protocol'] == 'tcp'
end.each do |ipp|
  ec2.revoke_security_group_ingress({
    group_id: gid,
    ip_permissions: [{
      ip_protocol: 'tcp',
      from_port: 22,
      to_port: 22,
      ip_ranges: ipp['ip_ranges']
    }]
  })
end
