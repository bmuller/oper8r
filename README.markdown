# Oper8r: Chef Solo Setup
This is a basic skeleton for setting up a chef solo deployment service.  You should have at least one running Ubuntu-based Amazon instance (though you don't need to do anything other than spin it up).

## Initial Setup
1. Install needed gems by running "bundle"
1. Put your keyfile that you set up in AWS in the keys directory.
1. In the folder cookbooks/sane/recipes you'll find three example roles for servers.  The "sane" recipe is used to bootstrap the servers to a sane environment.  The default file has packages that apply to all roles.  The web file has an example setup for a rails directory structure.  Basically, any set up that is specific to the role (i.e., webserver, db, proxy, whatever) should go into a file here.
1. Figure out what users should have have accounts on your systems and create files for them in kitchen/data_bags/users.  There's an example file there for a John Doe - note that the "ssh-keys" value should be the full text of the authorized public key that will be used to authenticate to the server (i.e., this is the public key that the user will use to gain access to the given account).
1. Put a private/public keypair into kitchen/cookbooks/sane/templates/default (there are skeleton files there now).  These will be installed on the server for the user identified in kitchen/cookbooks/sane/recipes/web.rb (look at the end of the file).  You may want to install known key pairs for all users - the reason it was done in the example for the web role is so that checkouts could be done from github using key based authentication.  If you want to do the same thing for github - you'll need to put github's public key in the authorized_keys file so you don't get a warning when checking out a repo.
1. The files in kitchen/roles are the config files for each role.  They specify which recipies will be run for each role.  The base role is config for every server.
1. Edit the config.yml file.  Come up with a shortname for your first host (called web0 as an example), and input the internal/external ips and the roles that apply to the given server.

## Initial Deployment
The following commands will bootstrap the server:

    export TARGET=server
    cap chef:bootstrap

Then, after the server has rebooted:

    cap chef:cook

## Future Updates
In the future, all you have to run is:

    TARGET=server cap chef:cook

where server is the short name for the host you want to update.