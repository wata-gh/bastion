require 'yaml'

CONFIG = YAML.load_file 'config.yml'
Aws.config = CONFIG[:aws_config]
