# Slurm Accounting

How the cluster bills your jobs, where the budget lives, and (most importantly)
**how to pick the right account when you have more than one**.

Audience: anyone running Slurm jobs. Multi-account users (rose member who is
also tagged to a faculty project, postdocs split across labs, etc.) should pay
particular attention to the *Multi-account users* section below — picking the
wrong `-A` will silently drain the wrong budget.

## The unit: SU (Service Unit)

One **SU = 1 billing-TRES-minute**. Every job is billed in SU based on what it
allocated and for how long.

The conversion from "GPUs × hours" to SU is the partition's
`TRESBillingWeights`. Current weights on `cluster02`:

| GPU model              | Weight | SU per GPU-hour |
|------------------------|-------:|----------------:|
| pro6000, pro6000-lowram |    8.0 |             480 |
| l40, 6000ada           |    4.0 |             240 |
| a40, a6000             |    3.0 |             180 |
| CPU only               |    0   |               0 |

**CPU-only jobs cost 0 SU** — useful for data prep, light interactive shells,
notebook edits, etc. Only GPU allocation drives billing.

Live values: `scontrol show partition cluster02` → `TRESBillingWeights`.

**Worked example.** A job with `--gpus=pro6000:2 --time=3:00:00` that runs to
completion bills:

```
2 GPUs × 3 hours × 480 SU/GPU-hour = 2,880 SU
```

The same wall-time on l40 would be 1,440 SU; on a40 it would be 1,080 SU.
Cheaper hardware drains your budget more slowly — this is intentional, and
nudges you toward less-contended models when your work doesn't need pro6000
specifically.

## Two dimensions: account (`-A`) and QoS (`--qos=`)

Every job has both:

- **Account** (`-A`, also called assoc): *which budget pocket pays for this job.*
  Examples: `rose`, `dso`, `faculty-proj`, a per-PI project account, etc.
- **QoS** (`--qos=`): *which queueing/limit policy applies, and which
  group-level budget pool the job draws from.* Examples: `rose`, `phd`, `ug`,
  `<pi>_2026_05`, `override-limits-but-killable`.

Slurm tracks usage **independently** at both levels. A job decrements both the
account's bucket *and* the QoS's bucket — every counter that has a cap defined
gets debited; counters with no cap are simply not tracked.

If you don't pass `-A` or `--qos=`, Slurm uses your `DefaultAccount` and
`DefaultQOS`. Inspect with `sacctmgr show user $USER -P` and
`sacctmgr show assoc user=$USER -P -o User,Account,DefaultQOS,QOS`.

## Multi-account users

If `sacctmgr show assoc user=$USER` returns more than one row, you have
multiple associations — typically because you're a regular `rose`/`phd`/etc.
member **and** you've been added to a faculty project.

**The account flag (`-A`) is what selects the budget.** This is the single
most important rule on this page:

```bash
# Drains the budget attached to your rose membership:
sbatch -A rose --qos=rose ...

# Drains the project's group budget (independent counter):
sbatch -A <project_account> --qos=<project_qos> ...
```

Switching `-A` is like swiping a different credit card — same human, same
home directory, same Linux UID, but a different bill.

**What happens if you mix the two:**
- `sbatch -A rose --qos=<project_qos>` — typically rejected if the project QoS
  isn't granted on your `rose` association (which is the recommended setup).
  If it *is* granted, the job draws from your rose account's budget AND the
  project QoS's pool simultaneously (double counting).
- `sbatch -A <project_account> --qos=rose` — likewise rejected unless `rose`
  QoS is granted on your project association (it usually shouldn't be).

**Recommended habit:** always set `-A` and `--qos=` *together*, matching the
intent. For sbatch scripts, write them at the top:

```bash
#SBATCH -A faculty-proj
#SBATCH --qos=wong_liangjie_2026_05
#SBATCH --gpus=pro6000:1
#SBATCH --time=4:00:00
```

If you have a project tag, set your shell's default to bill personal work
correctly by exporting `SLURM_ACCOUNT` / `SLURM_QOS`, or just always be
explicit on each submission.

### Why this design

The two-account split exists so that **project-funded compute does not eat
into your personal quota**, and your personal quota does not eat into your
project's budget. The budgets are kept on separate ledgers; you choose which
one to charge by which account you submit under.

If your project budget runs out, you can still do personal work (`-A rose`) up
to your personal cap. If your personal cap is exhausted, you can still do
project work (`-A <project_account>`) until the project's pool runs out.

## The `override-limits-but-killable` escape hatch

This QoS is a special "free preemptible scavenger" path. Jobs submitted with
`--qos=override-limits-but-killable` (often shortened to *OLBK*):

- Run on **idle GPUs only** — they don't preempt anyone else.
- Are **preempted (requeued) by any within-limit job** that wants the GPUs.
- **Cost zero SU** — no drain on either your account budget or any QoS pool.

OLBK is intended for backfill: chip away at a long sweep when GPUs sit idle,
without burning quota. The tradeoff is that your job can be requeued at any
time, so make sure to checkpoint frequently and use `--requeue` semantics
correctly.

OLBK works on *any* account you have access to. Submitting `-A rose
--qos=override-limits-but-killable` and `-A <project_account>
--qos=override-limits-but-killable` are equivalent — both run free.

See [Cluster Overview](cluster.md#Slurm) for the full preemption rule and
the rest of the QoS lineup.

## Inspecting your usage

```bash
# Your associations (which accounts you can use, and the QoS list per assoc):
sacctmgr show assoc user=$USER -P -o User,Account,DefaultQOS,QOS

# Your fairshare and rolling RawUsage on a given account:
sshare -u $USER -A <account>

# Project QoS budget and current consumption:
sacctmgr show qos <qos_name> -P format=Name,GrpTRESMins,GrpUsedTRES

# Your job history with billing per job (last 7 days):
sacct -u $USER -X --starttime=$(date -d '7 days ago' +%Y-%m-%d) \
      --format=JobID,Account,QOS,AllocTRES%60,ElapsedRaw,State -P
```

The `billing=N` field in `AllocTRES` is the SU-per-minute rate for that job;
multiply by `ElapsedRaw / 60` to get total SU consumed.

## Decay vs. lifetime budgets

Two flavors of cap exist on the cluster:

- **Personal/rolling caps** (set on user×account associations): decay over
  time, controlled by Slurm's `PriorityDecayHalfLife`. Effectively a "rolling
  N TRES-minutes available" — usage you accumulated months ago stops
  counting against you.
- **Project lifetime budgets** (set on project QoSes with `Flags=NoDecay`):
  do **not** decay. Once your project's `GrpTRESMins` is consumed, the QoS
  rejects new submissions until an admin tops up the budget or resets the
  ledger. This is by design — projects are funded for a fixed amount of
  compute, not an annual rolling allowance.

If your project QoS is exhausted and you have legitimate work pending,
contact your PI or the cluster admins. Don't try to bypass via `--qos=rose`
— see *Multi-account users* above.

## Common pitfalls

1. **Submitting project work without setting `-A`.** Your `DefaultAccount`
   gets used, which is usually `rose` — so the project's budget sits
   untouched while your personal cap drains. Set `#SBATCH -A` explicitly in
   sbatch scripts.

2. **Assuming "QoS = budget"** — QoS controls policy and group-level pools,
   but the *account* (`-A`) is what selects whose ledger pays. They're
   independent dimensions; both matter.

3. **Forgetting OLBK is free.** Long sweeps that don't have a hard deadline
   are perfect candidates for `--qos=override-limits-but-killable` — no
   quota drain, just the requeue risk.

4. **Multi-project users** with two project accounts: each project has its
   own independent budget. There is no "this human's total cluster usage"
   ceiling across them — admins track that out-of-band if needed. Be a good
   neighbor and don't double-spend by running concurrent heavy work on both.

5. **CPU-only jobs charged 0 SU is not a bug.** The billing weight for CPU is
   zero — if your job allocates no GPUs, it costs nothing. This is by policy.
   GPUs are the contended resource; CPU/RAM only matters via the per-user
   limits, not the budget.
