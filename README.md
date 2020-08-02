# GreeHost StaticServ

## Installation

This should be installed on a freshly provisioned CentOS 7 minimal install.  SSH is assumed to be installed and running.

```bash
# Install nginx, cpanm
yum install -y epel-release; yum update; yum -y upgrade; yum install -y nginx perl-App-cpanminus

# Allow HTTP(S) traffic to nginx
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

# Make a directory to store SSL certifcates and webroots
mkdir -p /etc/staticserv/ssl
chown root.nginx /etc/staticserv/ssl
chmod 0750 /etc/staticserv/ssl

mkdir -p /var/www
chown root.nginx /var/www
chmod 0750 /var/www

# Ask SELinux to please let us have access to files
chcon -Rt httpd_sys_content_t /var/www
chcon -Rt httpd_sys_content_t /etc/staticserv/ssl

# Start nginx
systemctl enable nginx
systemctl start nginx

# Install the GreeHost::StaticServ package (build this from this repo)
cpanm GreeHost-StaticServ-0.001.tar.gz

# Install an SSH Key so that GreeHost-Builder can configure websites
# through this, key generation is discussed in GreeHost-Builder.
```
