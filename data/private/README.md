#### Private

This directory contains all of the private data that you do not want placed in a public repo such as:

>Server inventory
>
>Keys
>
>Items specific to your organization

These items should live in a private repo somewhere such as Enterprise Github or a private Github repo. During the build process the data in your private repo will override what is here.

We have provided an example repo called https://github.com/cepheus-io/cepheus-private that shows you how to do it. Cepheus uses Layering Techniques along with powerful template features to make this possible and very easy to manage.

The final data file that gets built is called `build.yaml`. It does not get saved (in .gitignore) in a repo. The data files:

>/data/common.yaml
>
>/data/(public|private)/(local|whatever_you_want)/environment.yaml
>
>/data/(public|private)/(local|whatever_you_want)/(rhel|centos|ubuntu).yaml
>
>/data/(public|private)/(local|whatever_you_want)/racks.yaml

The `environment.yaml` will describe your environment that needs building. ANY files located in the `private` folder and not the sub-folder should be considered common between all data centers such as scripts etc.
