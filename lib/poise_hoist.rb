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

  # Run the attribute hoist process.
  #
  # @param node [Chef::Node] Node object to modify.
  # @return [void]
  def self.hoist!(node)
    policy_group = (defined?(node.policy_group) && node.policy_group) || \
                   Chef::Config[:policy_group] || \
                   (Chef::Config[:deployment_group] && Chef::Config[:deployment_group].split(/-/).last)
    # Don't continue if we aren't using policies.
    return unless policy_group
    Chef::Log.debug("Running attribute Hoist for group #{policy_group}")
    # Hoist away, mateys!
    Chef::Mixin::DeepMerge.hash_only_merge!(node.role_default, node.role_default[policy_group]) if node.role_default.include?(policy_group)
    Chef::Mixin::DeepMerge.hash_only_merge!(node.role_override, node.role_override[policy_group]) if node.role_override.include?(policy_group)
    # Install the patch for chef_environment.
    patch_chef_environment!(node, policy_group)
  end

  # Patch `node.chef_environment` to return the policy group name if enabled
  # via `node['poise-hoist']['hoist_chef_environment']`.
  #
  # @api private
  # @since 1.1.0
  # @param node [Chef::Node] Node object to modify.
  # @param policy_group [String] Policy group name.
  # @return [void]
  def self.patch_chef_environment!(node, policy_group)
    old_accessor = node.method(:chef_environment)
    # Not using Poise::NOT_PASSED because this doesn't depend on Poise.
    node.define_singleton_method(:chef_environment) do |*args|
      if args.empty? && node['poise-hoist']['hoist_chef_environment']
        policy_group
      else
        old_accessor.call(*args)
      end
    end
  end

end
