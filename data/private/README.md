#### Private

This directory contains all of the private data that you do not want placed in a public repo such as:

>Server inventory

>Keys

>Items specific to your organization

These items should live in a private repo somewhere such as Enterprise Github or a private Github repo. During the build process the data in your private repo will override what is here.

We have provided an example repo called https://github.com/cepheus-io/cepheus-private that shows you how to do it. Cepheus uses Layering Techniques along with powerful template features to make this possible and very easy to manage. 

The data files can be called anything you want as long as you update them in the build.yaml file.

Examples:

>base_data.yaml

>rack01_data.yaml

>rack02_data.yaml

>rack03_data.yaml

In the example above, `base_data.yaml` will contain all of the common data and data specific to the bootstrap node. As a reminder, the bootstrap node is the build, Chef, PXE boot and misc server. It can also have a Ceph role such as RGW (Rados Gateway) etc or not. After the cluster is built the resources the bootstrap node consumes is minimal.
