require 'spec_helper'

describe 'munin::node' do

  [ :CentOS, :Debian, :RedHat, :Ubuntu ].each do |sc|
    context "Check for supported operatingsystem #{sc}" do
      include_context sc
      it { should compile }
      it { should contain_class('munin::node') }
      it {
        should contain_package('munin-node')
        should contain_service('munin-node')
        should contain_file('/etc/munin/munin-node.conf')
      }
    end
  end

  [ :SmartOS ].each do |sc|
    context "Check for supported operatingsystem #{sc}" do
      include_context sc
      it { should compile }
      it { should contain_class('munin::node') }
      it {
        should contain_package('munin-node')
        should contain_service('smf:/munin-node')
        should contain_file('/opt/local/etc/munin/munin-node.conf')
      }
    end
  end

  context 'unsupported' do
    include_context :unsupported
    it {
      expect {
        should contain_class('munin::node')
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    }
  end

  context 'acl with ipv4 and ipv6 addresses' do
    include_context :Debian
    let(:params) do
      { allow: ['2001:db8:1::', '2001:db8:2::/64', '192.0.2.129', '192.0.2.0/25'] }
    end
    it do
      should contain_file('/etc/munin/munin-node.conf')
        .with_content(/^cidr_allow 192.0.2.0\/25$/)
        .with_content(/^cidr_allow 2001:db8:2::\/64$/)
        .with_content(/^allow \^192\\.0\\.2\\.129\$$/)
        .with_content(/^allow \^2001:db8:1::\$$/)
    end
  end

end
