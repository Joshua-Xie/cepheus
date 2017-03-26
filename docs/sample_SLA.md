# Sample Service Level Agreement (SLA)

*This is a sample SLA. Feel free to add, remove or edit in anyway that fits your needs for your Cepheus managed Ceph cluster*

The Service Level Agreement (SLA) formally defines the services offered by the Cloud Storage (CS) platform provider to its clients.

## SLA Common to All Projects

 1. 11 9's Durability across the cluster
 2. 99.95 Availability

## SLA During Maintenance Events

CS maintenance events are classified into small, medium, and large events.

- Small maintenance events cover a single node
- Medium maintenance events cover a single zone or rack
- Large maintenance events cover an entire cluster

Clusters generally keep running during small and medium maintenance events. Large maintenance events may involve full cluster reboot or even an extended full cluster off-period.

Other notable cluster events include new cluster launches, old cluster retirements, cluster capacity changes, Ceph rebalances, and Ceph recovery. These are documented in the [SLAs During Other Cluster Events](#slas-during-other-cluster-events) section.

### Small Maintenance Events

This category includes both planned and unplanned maintenance of a single node. Possible causes include planned node maintenance (for example, a server part recall), a sudden fault (for example, failure of an OS  disk, RAM, CPU, or fan), or a simple unexplained Linux system crash. No notification will be given for single events unless it is believe that it could impact the user.

### Medium Maintenance Events

This category includes events such as cluster patching. For an event such as a security advisory or OpenStack point release upgrade, all machines in a cluster typically need to be patched and restarted. To mitigate the impact, notification for medium events is provided one day to one week in advance. Maintenance only hit one AZ per day on a particular cluster. App-level SLAs may be maintained by ensuring that VMs are distributed across multiple AZs, such that the cluster temporarily losing one AZ does not take the application below minimum "strength" (in other words, the number of available VMs).

### Large Maintenance Events

This category includes events such as data center power-down exercises, hardware moves, power equipment maintenance, and switch equipment maintenance. Notification for large maintenance events is provided at least one, and typically several, weeks in advance with several repeat warnings. In these cases, the cluster is physically switched off, or at least not reachable on the network. Events such as these are kept to a minimum, but cannot be completely avoided. App-level SLAs are maintained entirely by serving all demand from the other data centers. This is compliant with the company disaster recovery standards, where applications are expected to be able to run when one out of two main data centers are completely down.

> **Note:** In the following sections, "App-level SLAs" refer to SLAs provided by applications running on a cluster which are built with multiple VMs (possibly using load balancing). These "cloud-native" applications are, therefore, capable of tolerating some cluster degradation. Since Cloud Storage clusters provide no particular SLA for a single VM instance, it follows that monolithic applications (those built with a single VM on a cluster) have no specific app-level SLA.

#### Planned Maintenance

Planned maintenance events include, but are not limited to, the following:

- Hardware maintenance (fan replacement, etc.)
- Software upgrades (for the OpenStack and hypervisor operating systems)
- Infrastructure upgrades.

##### Planned Maintenance Instance Impact

Instances are shut down through an Advanced Configuration and Power Interface (ACPI) shutdown, by a virtual power button press, prior to maintenance start. When the maintenance is complete, the instance is re-started.

> **Note:** Customers are responsible for ensuring that instances shut down cleanly, without hanging during shutdown or missing startup/shutdown scripts.  

#### Unplanned Maintenance

Unplanned maintenance events include, but are not limited to, the following:

 - Hardware failure (system board, CPU, etc.)
 - Emergency patching (high risk security patches)
 - Infrastructure failure (site loss).

##### Unplanned Maintenance Instance Impact

For failure modes, emergency patching, and infrastructure failures, instances are shut down prior to maintenance start and re-started when maintenance ends. In the event of a root disk failure on a hypervisor, all instances are lost.

> **WARNING:** Any disk failure on a non-durable hypervisor (an instance created with an "e1." flavor) will result in the loss of the instance.

### Proactive Maintenance Recommendations

The following recommendations help ensure successful maintenance events:

 - Terminate the instance pre-maintenance and recreate post-maintenance in the same AZ. Prior to a planned maintenance event, instances can be terminated and recreated in another AZ.
 - Verify that instances shut down and start up cleanly.
 - For High Availability (HA) instances, verify that the instances exist in different AZs and function at all data center sites.
 - Manually back up important data off the Cloud Storage cluster.

### Maintenance Notification Channels

For the latest information on Cloud Storage maintenance events, subscribe to the following:

 - Slack "...whatever_your_slack..."
 - Mailing List "...whatever_your_mailing_list..."
 - IRC "...whatever_your_IRC..."
 - whatever_else_you_use

## SLAs During Other Cluster Events

Other cluster events include:

- Lifecycle events, such as new clusters, cluster growth or shrinkage, and cluster decommissioning
- Ceph traffic spikes, such as rebalances and recovery.

### Cluster Lifecycle Events

#### New Clusters

When a new cluster is brought up, Cloud Storage declares it open for testing (i.e., in beta). Every effort is made to keep the cluster stable; however, if an error occurs in the  installation, a restart or even a rebuild may be necessary. During the beta period, no particular SLA is used; however, if the cluster works, it is declared operational immediately (through the WHATEVER_YOUR_COMMUNICATION_CHANNELS_ARE). From that point on, the SLAs will apply.

#### Cluster Capacity Changes

Running clusters may either grow or shrink. Routine maintenance may change capacity slightly, but there are also cases where multiple machines are added or removed from a cluster. In these cases, extra Ceph traffic may lead to performance degradation, but all services should continue to work. Any capacity change which is expected to cause very large Ceph traffic spikes is performed outside normal business hours, as described in the [Ceph Rebalances](#ceph-rebalances) section.

#### Cluster Decommissioning

When a cluster is decommissioned, all assets on the cluster are destroyed, and there are no backups. This means that all projects must copy valuable assets off cluster. To aid in this process, Cloud Storage provides extensive notification and a staged withdrawal according to a published timetable. This timetable typically involves the following steps, separated by at least one business day:

Step | Response
----- | -------
1. Initial notification of cluster end-of-life. | Cluster operationally unaffected. |
2. Stop all VMs (exceptions granted on request). | VMs may be restarted, all APIs are operational. |
3. Withdraw APIs for new VM launch. | Existing VMs still run. |
4. Stop cluster, recycle hardware. | All VMs killed, all volumes lost. |

### Ceph Traffic Spikes

#### Ceph Rebalances

At times it may be necessary to move a significant amount of data around within a cluster; in Ceph terminology, this is typically called a "rebalance." For example, a move may be necessary due to changes in the CRUSH map or in Cloud Storage's rack-diversity model.

> **Note:** Cloud Storage currently tries to keep the replicas of any particular object in different pods and often different racks).

Rebalancing traffic is throttled in a cluster-steady state. When such rebalances are necessary, Cloud Storage does one of the following, depending on the type of rebalance that is required:

- For minor rebalances, the rebalance is performed with Ceph throttled down during normal business hours, leaving cluster performance in its normal state
- For major rebalances, Ceph is allowed to run unthrottled outside of normal business hours; this allows the rebalance to occur more rapidly, but with a possible degradation in performance.

#### Ceph Object Recovery

When disks fail, Ceph creates new replicas of any impacted object, to re-establish the configured replica count (typically three replicas in current clusters). If a large number of disks fail at the same time (for example, due to physical damage of a rack), Ceph recovery traffic may become significant. This is entirely automatic and Cloud Storage currently does not control this recovery. For example, trying to postpone such recovery leads to risk of losing data, if more disks were to fail if a reduced number of replicas are available. Cluster performance may also be degraded at such times.
