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

require 'spec_helper'


describe PoiseHoist do
  let(:role_default_attributes) { {} }
  let(:role_override_attributes) { {} }
  let(:node) { chef_run.node }
  subject do
    # Apply our attributes
    node.role_default.update(role_default_attributes)
    node.role_override.update(role_override_attributes)
    # Set a policy_group. Run this late so our node doesn't get created before
    # all before blocks get a chance to run.
    if defined?(node.policy_group)
      node.policy_group = 'mygroup'
    else
      # Global side effect. ¯\_(ツ)_/¯
      Chef::Config[:policy_group] = 'mygroup'
    end
    # Run the hoist.
    PoiseHoist.hoist!(node)
    # Use the attributes as the subject.
    node.attributes
  end
  before do
    # A whole bunch of attribute data as a starting point for each test.
    role_default_attributes['baseline'] ||= {}
    role_default_attributes['baseline']['one'] = 1
    role_default_attributes['baseline']['two'] = 2
    role_default_attributes['baseline']['deep'] ||= {}
    role_default_attributes['baseline']['deep']['three'] = 3
    role_default_attributes['baseline']['deep']['four'] = [4]
    role_override_attributes['baseline'] ||= {}
    role_override_attributes['baseline']['one'] = 11
    role_override_attributes['top'] = 'hat'
  end

  context 'with no policy attributes' do
    its(%w{baseline one}) { is_expected.to eq 11 }
    its(%w{baseline two}) { is_expected.to eq 2 }
    its(%w{baseline deep three}) { is_expected.to eq 3 }
    its(%w{baseline deep four}) { is_expected.to eq [4] }
    its(%w{top}) { is_expected.to eq 'hat' }
  end # /context with no policy attributes

  context 'with a single default policy attribute' do
    before do
      role_default_attributes['mygroup'] ||= {}
      role_default_attributes['mygroup']['baseline'] ||= {}
      role_default_attributes['mygroup']['baseline']['two'] = 22
    end
    its(%w{baseline one}) { is_expected.to eq 11 }
    its(%w{baseline two}) { is_expected.to eq 22 }
    its(%w{baseline deep three}) { is_expected.to eq 3 }
    its(%w{baseline deep four}) { is_expected.to eq [4] }
    its(%w{top}) { is_expected.to eq 'hat' }
  end # /context with a single default policy attribute

  context 'with multiple default policy attributes' do
    before do
      role_default_attributes['mygroup'] ||= {}
      role_default_attributes['mygroup']['baseline'] ||= {}
      role_default_attributes['mygroup']['baseline']['one'] = 111
      role_default_attributes['mygroup']['baseline']['two'] = 22
      role_default_attributes['mygroup']['baseline']['deep'] ||= {}
      role_default_attributes['mygroup']['baseline']['deep']['three'] = 33
    end
    its(%w{baseline one}) { is_expected.to eq 11 }
    its(%w{baseline two}) { is_expected.to eq 22 }
    its(%w{baseline deep three}) { is_expected.to eq 33 }
    its(%w{baseline deep four}) { is_expected.to eq [4] }
    its(%w{top}) { is_expected.to eq 'hat' }
  end # /context with multiple default policy attributes

  context 'with an array default policy attribute' do
    before do
      role_default_attributes['mygroup'] ||= {}
      role_default_attributes['mygroup']['baseline'] ||= {}
      role_default_attributes['mygroup']['baseline']['deep'] ||= {}
      role_default_attributes['mygroup']['baseline']['deep']['four'] = [44]
    end
    its(%w{baseline one}) { is_expected.to eq 11 }
    its(%w{baseline two}) { is_expected.to eq 2 }
    its(%w{baseline deep three}) { is_expected.to eq 3 }
    its(%w{baseline deep four}) { is_expected.to eq [44] }
    its(%w{top}) { is_expected.to eq 'hat' }
  end # /context with an array default policy attribute

  context 'with a single override policy attribute' do
    before do
      role_override_attributes['mygroup'] ||= {}
      role_override_attributes['mygroup']['baseline'] ||= {}
      role_override_attributes['mygroup']['baseline']['one'] = 111
    end
    its(%w{baseline one}) { is_expected.to eq 111 }
    its(%w{baseline two}) { is_expected.to eq 2 }
    its(%w{baseline deep three}) { is_expected.to eq 3 }
    its(%w{baseline deep four}) { is_expected.to eq [4] }
    its(%w{top}) { is_expected.to eq 'hat' }
  end # /context with a single override policy attribute

  context 'with a top-level override policy attribute' do
    before do
      role_override_attributes['mygroup'] ||= {}
      role_override_attributes['mygroup']['top'] = 'dog'
    end
    its(%w{baseline one}) { is_expected.to eq 11 }
    its(%w{baseline two}) { is_expected.to eq 2 }
    its(%w{baseline deep three}) { is_expected.to eq 3 }
    its(%w{baseline deep four}) { is_expected.to eq [4] }
    its(%w{top}) { is_expected.to eq 'dog' }
  end # /context with a top-level override policy attribute

  describe 'patch_chef_environment!' do
    context 'with patching enabled (default)' do
      it { subject; expect(chef_run.node.chef_environment).to eq 'mygroup' }
    end # /context with patching enabled (default)

    context 'with patching disabled' do
      before { override_attributes['poise-hoist'] = {'hoist_chef_environment' => false} }
      it { subject; expect(chef_run.node.chef_environment).to eq '_default' }
    end # /context with patching disabled
  end # /describe patch_chef_environment!
end
