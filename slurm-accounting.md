# Slurm Accounting

We are enabling GPU hour billing for all users. For student users with personal
accounts, your limit is reset monthly at the first day of every month. For faculty
project users, the GPU hours are billed towards your assigned QoS instead of your 
account. Project members within the same project share a single quota.

Additionally, we prohibit dual account users, i.e., either you own a personal
account, or you are tagged under a faculty project. Whenever you have a faculty 
project assigned, your personal account will be suspended. This is to prevent 
double-assigning GPU hours.

## The smallest unit: SU (Service Unit)

One **SU = 1 billing-TRES-minute**. Every job is billed in SU based on what it
allocated and for how long.

The conversion from "GPUs × hours" to SU is the partition's
`TRESBillingWeights`. Current weights on `cluster02`:

| GPU model              | Weight | SU per GPU-hour |
|------------------------|-------:|----------------:|
| pro6000                |    8.0 |             480 |
| l40, 6000ada           |    4.0 |             240 |
| a40, a6000             |    3.0 |             180 |
| CPU only               |    0   |               0 |

**CPU-only jobs cost 0 SU** — useful for data prep, light interactive shells,
notebook edits, etc. Only GPU allocation drives billing.

A job with `--gpus=pro6000:2 --time=3:00:00` that runs to completion bills:

```
2 GPUs × 3 hours × 480 SU/GPU-hour = 2,880 SU
```

The same wall-time on l40 would be 1,440 SU; on a40 it would be 1,080 SU. Hence,
to stretch your quota further, consider downgrading to a cheaper GPU model when
your job does not really need pro6000.

## Accounting principles

By default Slurm will always bill to account or user level. To ensure the student
and faculty tracks are enforced correctly, please read the following differences
carefully.

For personal users:

Your quota is enforced on user level (note: Slurm use the word 'account' as a concept
of grouping). When submit a job with a QoS (if you do not specify the qos, it is calling
your default qos in the background), Slurm will bill you using the GPU hour you burned
times the `UsageFactor` that the QoS you used have.

For example, standard `rose` or `phd` QoS have a billing factor of `1.0`, thus when you spend
x amount of hours, your usage is recorded as-is. But when you submit a job under `override-limits-but-killable`,
your billing factor is 0 and hence your recorded usage will not increase.

For faculty project users:

Your quota is enforced on the QoS level, meaning your user and account level have
unlimited quota but your QoS is capped at whatever GPU hours you requested in your
application. Note that all members of the same project share a single quota — and
because the queue is private per user, you cannot see your colleagues' jobs, yet
their jobs still drain your shared project quota.

See below on how to invoke a particular QoS when submitting a job.
```bash
#SBATCH -A faculty-proj
#SBATCH --qos=your_supervisor_qos
#SBATCH --gpus=pro6000:1
#SBATCH --time=4:00:00
```

Always specify both `-A` and `--qos=` together so your jobs land on the intended
project budget. You can also set defaults in your shell via `SLURM_ACCOUNT` /
`SLURM_QOS` to avoid forgetting on each submission.

## The `override-limits-but-killable` escape hatch

This QoS is a special "free preemptible scavenger" path. Jobs submitted with
`--qos=override-limits-but-killable`:

- Run on **idle GPUs only** — they don't preempt anyone else.
- Are **preempted (requeued) by any within-limit job** that wants the GPUs.
- **Cost zero SU** — no drain on either your account budget or any QoS pool.

This QoS is intended for backfill: chip away at a long sweep when GPUs sit idle,
without burning quota. The tradeoff is that your job can be requeued at any
time, so make sure to checkpoint frequently and use `--requeue` semantics
correctly.

Certain users do not have this QoS. Please understand this is by design and not a
misconfiguration.

See [Cluster Overview](cluster.md#Slurm) for the full preemption rule and
the rest of the QoS lineup.

## Inspecting your usage

```bash
# Your own associations (accounts you can use, QoSes per assoc):
sacctmgr show assoc user=$USER

# Your fairshare and current month's RawUsage on a given account:
sshare -U -nP -o GrpTRESMins,GrpTRESRaw | awk -F'|' '{match($1,/billing=([0-9]+)/,c); match($2,/billing=([0-9]+)/,u); if (c[1]>0) printf "%d / %d SU (%.1f%%, %d remaining, %.1f / %.0f pro6000-hr)\n", u[1], c[1], 100*u[1]/c[1], c[1]-u[1],
  u[1]/480, c[1]/480; else print "No personal cap on this account."}'

# Your assigned project QoS quota usage state (define qos=your_qos first):
qos=your_qos
scontrol show assoc_mgr qos="$qos" 2>/dev/null | awk -v q="$qos" '/^QOS Records/{f=1} f && /GrpTRESMins=/{match($0,/billing=([0-9]+|N)\(([0-9]+)\)/,m); cap=(m[1]=="N")?"no-cap":m[1]; used=m[2]; if(cap=="no-cap") printf "%s: %s SU used (%.1f pro6000-hr), no cap\n", q, used, used/480; else printf "%s: %s / %s SU (%.1f%%, %.1f pro6000-hr used)\n", q, used, cap, 100*used/cap, used/480; exit}'
```

### Cap exhaustion

When your `GrpTRESRaw[billing]` reaches the cap, new submissions go pending
with a reason like `AssocGrpBillingMinutesLimit`. Already-running jobs
continue (Slurm's `safe` mode pre-checked they'd fit when they started).
Resolution paths:

1. **Wait for the 1st of next month** — the natural reset.
2. **Use a free QoS** — `--qos=override-limits-but-killable` for preemptible
   work, or your project QoS if applicable.
3. **Run CPU-only work** — no billing impact.
4. **Talk to admins** — manual mid-month resets are possible but treated as
   exceptions, not routine.

