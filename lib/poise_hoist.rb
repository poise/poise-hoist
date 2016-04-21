#
# Copyright 2016, Noah Kantrowitz
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

require 'chef/mixin/deep_merge'


# Helpers to hoist group-level attributes from a Policyfile.
#
# @since 1.0.0
module PoiseHoist
  autoload :VERSION, 'poise_hoist/version'

  def self.hoist!(node)
    # Do nothing if we aren't using policies.
    return unless node.policy_group
    # Hoist away, mateys!
    Chef::Mixin::DeepMerge.hash_only_merge!(node.role_default, node.role_default[node.policy_group]) if node.role_default.include?(node.policy_group)
    Chef::Mixin::DeepMerge.hash_only_merge!(node.role_override, node.role_override[node.policy_group]) if node.role_override.include?(node.policy_group)
  end
end
