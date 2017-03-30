#### Public

This directory contains all of the public data that you do not need placed in a private repo.

The data file that gets built in each sub-folder of this public directory is called `build.yaml`. It contains the unique data for the given sub-folder. The default sub-folder is called `local` which represent a pseudo local data center. Of course, you can name it anything you like. Just make sure to pass the correct value into ./CEPH_UP.

The `local` sub-folder name holds the default vagrant build information as an example. For real production environments it's suggested that you use the `private` sub-folder instead of this one.

ANY files located in the `public` folder and NOT the sub-folders should be considered common to all data centers.

OS specific data files should be in both 'public' and 'private'. Once passed through the template engine the output will go into the sub-folder of the specified data center.

#### Racks on different subnets and PXE Booting

Depending on the ToR (top of rack) switch you use, if you put each rack on a different subnet then you may need to do something like the following:

>IP helper-address `ip address of dhcp for pxe booting`
>
>set forwarding-option dhcp-relay server-group DHCP_SERVERS `ip address of dhcp of pxe booting`

The above may not be complete for your environment so get with your network team to determine the best way to pxe boot off of different subnets based on dhcp of your pxe server.
