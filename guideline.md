# Usage Guidelines

The EEE GPU Cluster is maintained by a small group of administrators who also
have their own academic, professional, and personal commitments. While we
strive to keep the cluster operational, please note that **any form of support
requests, updates and/or fixes may be delayed**. As such, you are recommended
to check [troubleshooting guide](troubleshooting.md) where we list some issues
encountered by users in the past.

## 1. Scope of Support

**Administrators are only responsible for cluster-related issues**. We will
not provide support for debugging or fixing your own code.

Generally speaking, if your code works locally on your machine and doesn't work
due to cluster-specific reasons, we will attempt to assist you. To help save
your time, check out the [FAQ](troubleshooting.md) before attempting to contact
the administrators.

You are expected to conduct yourself professionally when interacting with
cluster administrators. Please do your due dilligence and attempt to look for
solutions as maintaining the cluster is not our full-time job. You are expected
to:

- Search for answers in this repository
- Read our update logs, as posted in the MOTD
- Provide us with details on what you have tried to save everyone's time

Please understand that not doing the above will simply waste everyone's time and
resources.

**DO NOT send emails directly to any administrator's personal email address.**
This makes it impossible for us to track support requests and will simply cause
longer response time as other administrators will not be able to answer. It is
likely that your email will be ignored if you do so.

## 2. Availability & Security

While we do make an effort, **we cannot guarantee that your data is secure and
available at all times.**

This means that despite our best effort, we cannot guarantee fully that any of
the tasks that you are running will not be killed. We will attempt to inform you
should we suspect that this has happened, but we cannot fully guarantee this
either as we are not staring at the cluster 24/7.

**Please make backups of important data regularly.** We may be unable to assist
you in the case of data loss or if there are ongoing maintenance events.

For scheduled maintenance events, we typically attempt to announce 3 days prior
to the actual event. These events will be notified via email. **All jobs are
subject to be killed when the maintenance window starts and you may run into
issues attempting to use the cluster during the maintenance.**

## 3. Fair Usage & Queueing

- **DO NOT USE LOGIN NODES FOR HEAVY WORKLOADS**.

    To provide everyone with as much computational power as possible, we have
    deliberately made the login nodes low-powered. As such, they are very
    easily overwhelmed. Use compute nodes instead for any heavy-lifting.

    **We WILL terminate any processes that are putting an excessive load on
    login nodes and may restart them as necessary.** In addition, the cluster's
    connection to NTUSECURE may not be completely stable and you may disconnect
    at any time. Consider yourself warned.

    Currently, we enforce a hard 8 GB RAM per user limit on login nodes. Users
    exceeding this limit may see their processes killed by the kernel. This
    number may have changed and is only included here as a rough gauge.

- **Respect other users' right to access resources**.

    If you need to wait in the job queue, please understand that **all users
    under the same organization have equal priority**.

    Cluster hardware is funded by **multiple entities** at a cost of millions.
    Some GPU models or nodes may have restricted access based on the funding
    source's policies.

    Please **respect these access limitations**, or discuss additional resource
    contributions with your supervisor. Wherever possible, we have already
    included ways for you to request more resources in ways that will not
    disrupt other users' uses of the cluster.

    We regret to inform that we will not reply favourably to emails requesting
    for additional resources without contribution.

- **Release resources as soon as possible.**

    It is highly likely that other users are queueing for the resources that
    you are currently using, please be a good user and release as soon as
    possible so other users can use resources. Leaving the resources idle is
    insufficient, please exit the job completely to release your resources.

    This means that you should avoid running jobs that will not effectively use
    resources, including but not limited to, a normal `bash` shell to "reserve"
    resources. Run your individual scripts individually instead and keep your
    shell on login nodes.

    To ensure fair share, users that have used less resources recently will get
    a priority boost. As such, this will benefit not just other users but also
    you yourself.

## 4. Permitted Use

- The cluster is for **research and project-related computing** only.

- **Absolutely prohibited activities** include:
  - Running **illegal, unlicensed, or pirated software**.
  - Running **malicious software**, including viruses, worms, or scripts that
    would otherwise prevent other users from accessing the service.

- **If you run illegal or unlicensed software:**
  - **You are solely and fully responsible** for any and all consequences,
    including but not limited to:
    - Permanent loss of cluster access.
    - Financial penalties, including damages claimed by copyright or IP owners.
    - Disciplinary actions by your school, university, or relevant authorities.
  - The administrators have **warned you in advance** and will **not bear any
    responsibility** for your actions.

- Report any vulnerabilities to administrators immediately.
  - Usage of such vulnerabilities will lead to an immediate ban.

- Please be professional when using the cluster. This includes but is not
  limited to, using appropriate names for projects.
