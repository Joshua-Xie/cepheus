#### Common

This directory contains all of the common code used during the bootstrapping of an environment.

* `bootstrap_prereqs.sh` - This file is the most important since it's where all of the  Prerequisites of the build and deploy are gathered and saved in the `$HOME/.ceph-cache` directory. You will add new prerequisites when needed and update the versions of existing ones here.

* `bootstrap_proxy_setup.sh` - This file will setup the proxy environment if it exists.

* `bootstrap_validate_env.sh` - This file will check the environment variables for the must have ones.
