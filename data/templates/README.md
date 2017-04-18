#### Templates

This is a very important directory. It contains Jinja2 style templates that the Python code `template_engine` uses to merge all of the data into. The data is in the directory above this (parent) called `data`.

>Directories within this directory represents where the output of the given template will go. For example, `bootstrap/common/bootstrap_prereqs.sh.j2` will output to `bootstrap/common/bootstrap_prereqs.sh`.

* `base_environment.json.j2` - This file is the base environment file that will get created by the build process that will become your Chef Environment file such as `production.json` or whatever you want to call it. Once that final json file is created it will be what drives Chef to build out your environment.

* `cepheus_bootstrap_rhel.ks.j2` - This file is the RHEL/CentOS Kickstart file used by the build ISO that automatically sets up your bootstrap server which drives everything! The bootstrap node is a build server that runs the Chef Server, PXE Boot Server, Ansible Inventory for orchestration of common tasks across your fleet of Ceph nodes.

* `cepheus_node_rhel_nonosd.ks.erb.j2` - This is a RHEL/CentOS Kickstart file that is used to build (PXE Boot) NON-OSD nodes. This file goes through multiple phases. The first phase (Jinja2) builds the base data needed by Chef. The second phase is done by Chef to create the correct kickstart file used by the PXE Boot Server.

* `cepheus_node_rhel_osd.ks.erb.j2` - This is the same as the previous file except it's for actual OSD nodes.

* `isolinux.cfg` - This is a custom ISO Linux config file used by the bootstrap server itself. It changes the grub menu options etc of the ISO.

* `isolinux.cfg.j2` - This is similar to the previous file except it's for default ISO that gets built on the bootstrap node that is later used as the ISO used for PXE booting.

* `template_engine` - Main Python template engine used to take any Jinja2 template and any json/yaml input file to then render a given output file.
