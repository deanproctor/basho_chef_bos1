maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures nslcd"
version           "0.1"
suggests          "openldap"

recipe "nslcd", "Installs and configures nslcd"

%w{ redhat centos debian ubuntu }.each do |os|
  supports os
end
