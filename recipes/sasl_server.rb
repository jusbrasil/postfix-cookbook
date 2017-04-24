include_recipe "postfix"

package "sasl2-bin"
package "libsasl2-modules"

domain = node['postfix']['smtpd_sasl_domain']
username = node['postfix']['smtpd_sasl_user_name']
password = node['postfix']['smtpd_sasl_passwd']

execute "create saslauthd folder" do
  command "dpkg-statoverride --force --add root sasl 710 /var/spool/postfix/var/run/saslauthd"
end

execute "add sasl user" do 
  command "adduser postfix sasl"
end

execute "write-password-input" do
  command "echo \"#{password}\" > /tmp/saslpass" 
end

execute "write-password-input" do
  command "saslpasswd2 -c -u #{domain} #{username} -p < /tmp/saslpass" 
  user "root"
  group 0
end

execute "write-password-input" do
  command "rm /tmp/saslpass" 
end

template "/etc/default/saslauthd-postfix" do
  source "saslauthd-postfix.erb"
  owner "root"
  group 0
  mode 644
end

template "/etc/postfix/sasl/smtpd.conf" do
  source "sasl_smtpd.conf.erb"
  owner "root"
  group 0
  mode 644
end

