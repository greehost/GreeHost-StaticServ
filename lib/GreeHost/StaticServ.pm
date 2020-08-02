# ABSTRACT: Provide RPC Functions for GreeHost StaticServ Nodes
package GreeHost::StaticServ;
use warnings;
use strict; 
use IPC::Run3;
use File::Temp;
use File::Find;
use File::Path qw( remove_tree );
use File::Copy;

sub install_domain {
    my ( $dir ) = @_;

    # Find the domain we're working with.
    my @files;
    find( sub { $_ =~ /\.conf$/ && push @files, $_ }, $dir );
    die "Error: Expected one *.conf file in $dir, found " . scalar(@files)
        unless @files == 1;

    # The config file is always names "${FQDN}.conf"
    my $domain = substr( $files[0], 0, -5 );
    
    # Purge anything in /var/www/$domain and then copy our root over.
    remove_tree( "/var/www/$domain" );
    mkdir( "/var/www/$domain" );
    run3([ qw( tar -xzf ), "$dir/webroot.tgz", '-C', "/var/www/$domain" ] );

    # Copy over the actual configuration file.
    copy( "$dir/$domain.conf", "/etc/nginx/conf.d/$domain.conf" ); 
    
    # Reload nginx to respect the new configuration file.
    # TODO: You should make sure that domain.conf file is valid before copying/restarting,
    #       nginx won't reload with an invalid config, but you need some kind of NOC notification
    #       for that event, since all nginx will be blocked for all domain config changes.
    run3( [qw( nginx -s reload )] );

    return 1;
}

1;
