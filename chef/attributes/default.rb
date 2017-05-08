#
# Copyright 2016-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Name for attribute data bag. Defaults to nil, meaning the feature is disabled.
default['poise-hoist']['data_bag'] = nil

# Enable node.chef_environment by default.
default['poise-hoist']['hoist_chef_environment'] = true

# If we weren't able to run it during library load, do it now.
PoiseHoist.hoist!(node) unless defined?(Chef.node)
