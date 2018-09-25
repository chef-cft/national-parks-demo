#!/usr/bin/env ruby

AWS_SDK_REQUIRED_VERSION = '3.0'
AWS_REGION = ENV['AWS_DEFAULT_REGION'] ||'us-west-2'

def usage()
  raise "\n\nUnable to create dashboard, to run this script make sure you have: \n\
           * Gem aws-sdk >= #{AWS_SDK_REQUIRED_VERSION} \n\
           * terraform.tfstate generated from running 'terraform apply'\n
           * Run the script from the root of the repository.\n\n"
end

require 'aws-sdk'
usage() if ! defined?(Aws::CORE_GEM_VERSION) ||
           Gem::Version.new(Aws::CORE_GEM_VERSION) <= Gem::Version.new(AWS_SDK_REQUIRED_VERSION) ||
           ! File.exist?('terraform.tfstate')

require 'erb'
require 'json'


stateFile = File.read('terraform.tfstate')
dashFile  = File.read('scripts/dashboard.erb')

tfState  = JSON.parse(stateFile)
name   = tfState['modules'][0]['resources']['aws_instance.chef_automate']['primary']['attributes']['tags.Name']
randomId = tfState['modules'][0]['resources']['random_id.instance_id']['primary']['attributes']['hex']
dashBoardName = "#{name}_#{randomId}"

renderer = ERB.new(dashFile)

#these steps minify the json bypassing entityTooLarge errors
dashHash = JSON.parse(renderer.result())
dashJson = JSON.generate(dashHash)

cloudWatch = Aws::CloudWatch::Client.new(region: AWS_REGION)
cloudWatch.put_dashboard({
  dashboard_name: dashBoardName,
  dashboard_body: dashJson,
})
puts "https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=#{dashBoardName}"
