test_name "Installing Puppet" do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  version = ENV['PUPPET_VERSION'] || '3.6.2'
  download_url = ENV['WIN_DOWNLOAD_URL'] || 'http://downloads.puppetlabs.com/windows/'
  hosts.each do |host|
    if host['platform'] =~ /windows/
      install_puppet_from_msi(host,
                              {
                                  :win_download_url => download_url,
                                  :version => version
                              })
      step "Install Registry to host"
      on host, "mkdir -p #{host['distmoduledir']}/registry"
      result = on host, "echo #{host['distmoduledir']}/registry"
      target = result.raw_output.chomp

      %w(lib manifests metadata.json).each do |file|
        scp_to host, "#{proj_root}/#{file}", target
      end
      on host, 'curl -k -o c:/puppetlabs-stdlib-4.5.1.tar.gz https://forgeapi.puppetlabs.com/v3/files/puppetlabs-stdlib-4.5.1.tar.gz'
      on host, puppet('module install c:/puppetlabs-stdlib-4.5.1.tar.gz --force --ignore-dependencies'), {:acceptable_exit_codes => [0, 1]}
    end
  end
end
