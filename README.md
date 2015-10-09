# bastion

Bastion is a web application maintains AWS Security Groups.

# Installation

```shell
# clone source
git clone https://github.com/wata-gh/bastion.git

# bundle install gems
bundle --path vendor/bundle

# npm install
npm install

# run gulp
gulp

# run unicorn
RACK_ENV=production ./script/unicorn
```

## Capistrano

If you are using capistrano, you can set environment settings and deploy.

```shell
bundle exec cap production deploy
```

## Setup Configuration

```yaml
:app:
  :name: bastion
:aws_config:
  :access_key_id: '[Your Access Key]'
  :secret_access_key: '[Your Secret Key]'
  :region: 'ap-northeast-1'
:security_group:
  :bastion:
    :group_id: '[bastion Security Group Id. e.g. sg-xxxxxxxx]'
    :defaults: ['1.1.1.1:22']
  :webservice:
    :group_id: '[web server(maybe elb) Security Group Id. e.g. sg-xxxxxxxx]'
    :defaults: ['1.1.1.1:80']
```

## Security Group Reset Batch

Set security group reset batch and reset everyday.
This program will revoke security group ingress except default IPs set on above.
Here is a sample crontab.

```
0 * * * * /opt/bastion/script/sgreset
```
