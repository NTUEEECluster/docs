# Usage Guidelines

The EEE GPU Cluster is maintained on a best-effort basis by a small group of
administrators who also have their own academic and professional commitments.
**Support requests, updates and/or fixes may be delayed**. Always check the
[troubleshooting guide](troubleshooting.md) before contacting us.
encountered by users in the past.

Liability Disclaimer:

THE CLUSTER IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE CLUSTER OR THE USE OR OTHER DEALINGS IN THE CLUSTER.

## 1. Scope of Support

**We only support cluster infrastructure**. We do not debug user code.

- We WILL help if: Your code works locally but fails on the cluster (see
  [FAQ](troubleshooting.md)).
- We WILL NOT help if: Your code has logic issues, integration issues, or bugs.

Below is a more detailed version of what you can expect from us:

| Type | Response | Examples |
|----|----|----|
| Bug Reports (issues in cluster components) | ASAP | NVML errors, unresponsive Slurm |
| Service Requests | Up to 3 working days, best-effort basis | Password reset, account reactivation |
| Guideline-Violating Requests | Ignored; Escalation on repeated offense | Additional resource request, Expedition requests |

We have a [Support Checklist](troubleshooting.md#Support-Checklist) to help save
both our and your time.

You are expected to conduct yourself professionally when interacting with
cluster administrators. Please do your due dilligence and attempt to look for
solutions as maintaining the cluster is not our full-time job.

## 2. Cluster Availability

### No Uptime Guarantee

The cluster is maintained on a best-effort basis. There are no 24/7 on-calls
monitoring the cluster. Jobs may be killed unexpectedly.

### Maintenance

We aim to notify users 2-3 days prior to scheduled maintenance events via email.
**All jobs are subject to be killed when the maintenance window starts and you
may run into issues attempting to use the cluster during the maintenance.**

## 3. Data Privacy & Availability

Your data is NOT backed up by us. You are responsible for your own backups. Your
data is not retrievable when the cluster is unavailable.

Your files are private, unless you have granted permission to other people. Your
files may be accessed by admins and your approver (e.g. supervisor or course
coordinator) for troubleshooting, auditing, or compliance.

We delete your data if:
- You have not logged in for 6 months (with a reminder before this happens)
- Your applied usage period has expired (e.g. course users during end of
  semester)

You are responsible for activities that have been conducted using your
credentials. Keep them secure. Sharing accounts with other people will still
make you liable.

## 4. Fair Usage & Queueing

- **DO NOT USE LOGIN NODES FOR HEAVY WORKLOADS**.

    Login nodes are low-power. There is an enforced CPU and RAM limit for every
    user. Running heavy tasks may result in:

    - Your shell/IDE being unusable due to CPU caps.
    - Your processes being killed as they hit the RAM limit.

    You are recommended to use [Slurm](slurm.md) for any heavy tasks, even if
    they do not require GPUs.

- **Respect other users' right to access resources**.

    - Least Recently Used First: In the same organization, users that have used
      the least resources recently have the highest priority.

    - No Hoarding: Do not run idle jobs (e.g., leaving a shell open inside a GPU
      node) just to "reserve" it. **Ensure you exit the job fully** when the
      resources are not being used. This is currently being actively audited.

    - Resource Limits: Access depends on funding sources and costs for the
      cluster is currently on the million scale. Do not email us asking for more
      resources unless your group is contributing hardware and you are the point
      of contact.

## 5. Permitted Use

The cluster is strictly for **research and project-related computing** only.

- **Strictly prohibited activities**:
  - Crypto-mining or commercial use.
  - Malicious Software: Viruses, worms, or scripts that would disrupt cluster
    service for other users.
  - Illegal Software: Pirated or unlicensed software.
  - Vulnerabilities: Vulnerabilities or exploits that abuse the cluster in
    unintended ways.

- **Likely Consequences**:
  - Immediate Ban: Your access will be revoked immediately when we receive such
    reports.
  - You are liable for all the damages incurred to the cluster as a result of
    your activities, including but not limited to:
    - Financial penalties, including damages claimed by copyright or IP owners.
    - Disciplinary actions by your school, university, or relevant authorities.

Please also be professional when using the cluster. This includes but is not
limited to, using appropriate names for projects.

## 6. Fair Use Policy

We have in good faith made the access for GPUs in the cluster available for
everyone as much as we can, subject to funding source restrictions. You are
expected to uphold your part by only requesting resources that you need. You may
be subjected to more auditing if you have higher than normal usage.
