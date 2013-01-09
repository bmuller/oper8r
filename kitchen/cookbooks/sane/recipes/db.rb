include_recipe "sane"

pkgs = %W(mysql-server redis-server)
pkgs.each { |pkg| package pkg }
