pkgs = %W(git mysql-client emacs monit)
pkgs.each { |pkg| package pkg }
