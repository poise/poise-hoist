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

require 'chef/encrypted_data_bag_item/check_encrypted'
require 'chef/mixin/deep_merge'


# Helpers to hoist group-level attributes from a Policyfile.
#
# @since 1.0.0
module PoiseHoist
  extend Chef::EncryptedDataBagItem::CheckEncrypted

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
    # Grab from a data bag if one is configured. Remember this might run very
    # early on newer Chef versions, before attribute loading.
    hoist_from_data_bag!(node, policy_group, node['poise-hoist']['data_bag']) if node['poise-hoist'] && node['poise-hoist']['data_bag']
    # Install the patch for chef_environment.
    patch_chef_environment!(node, policy_group)
  end

  # Pull attribute data in from a data bag. Checks for an item matching the
  # node node, and then the policy group.
  #
  # @api private
  # @param node [Chef::Node] Node object to modify.
  # @param policy_group [String] Policy group name.
  # @param data_bag [String] Data bag name to load from.
  # @return [void]
  def self.hoist_from_data_bag!(node, policy_group, data_bag)
    item = begin
      data_bag_item(data_bag, node.name)
    rescue Exception
      data_bag_item(data_bag, policy_group)
    end
    Chef::Mixin::DeepMerge.hash_only_merge!(node.role_override, item)
  end

  # A copy of Chef's data_bag_item method, modified to remove some spurious
  # error logging and returns a plain hash without the `id` field instead of
  # one of the data bag item objects.
  #
  # @api private
  # @param bag [String] Data bag name.
  # @param item [String] Data bag item name.
  # @param secret [String, nil] Data bag secret.
  # @return [Hash]
  def self.data_bag_item(bag, item, secret = nil)
    Chef::DataBag.validate_name!(bag.to_s)
    Chef::DataBagItem.validate_id!(item)

    item = Chef::DataBagItem.load(bag, item)
    data = if encrypted?(item.raw_data)
      Chef::Log.debug("Data bag item looks encrypted: #{bag.inspect} #{item.inspect}")

      # Try to load the data bag item secret, if secret is not provided.
      # Chef::EncryptedDataBagItem.load_secret may throw a variety of errors.
      secret ||= Chef::EncryptedDataBagItem.load_secret
      Chef::EncryptedDataBagItem.new(item.raw_data, secret).to_hash
    else
      item.raw_data
    end
    data.delete('id')

    data
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
