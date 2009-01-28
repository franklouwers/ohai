#
# Author:: Benjamin Black (<bb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# NOTICE - based on contributions from Tim Dysinger and Ezra Zygmuntowicz

require 'open-uri'

require_plugin "hostname"

def metadata(id='')
  open("http://169.254.169.254/2008-02-01/meta-data/#{id}").read.
    split("\n").each do |o|
    key = "#{id}#{o.gsub(/\=.*$/, '/')}"
    if key[-1..-1] != '/'
      ec2[key.gsub(/\-|\//, '_').to_sym] = begin
        value = open("http://169.254.169.254/2008-02-01/meta-data/#{key}").
          read.split("\n")
        value.size > 1 ? value : value.first
      end
    else
      metadata(key)
    end
  end
end

if domain =~ /\.amazonaws.com$/
  ec2 = Mash.new
  metadata
end