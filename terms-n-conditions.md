# Terms and Conditions

By logging in you accept these terms. Breaking them, knowingly or not, leads to
warnings, account suspension or a ban, and may be reported to your school or
the university.

## 1. Eligibility and accounts

- The cluster serves EEE students, staff and faculty, for research and
  coursework only. Use by anyone outside EEE, or for unrelated work, leads to an
  immediate ban.
- Student applications open at the start of each semester and stay open for one
  month. Outside this window they cannot be processed. Applications are handled
  in batches; requests to expedite are not accommodated.
- Faculty project calls are announced separately when capacity allows.
- Your login details arrive by email once approved. Contact us only if they do
  not work.
- Resource limits and quotas are fixed per user group and set by the funding
  behind the hardware. Increases are not available unless your group contributes
  hardware and you are its point of contact.
- A user holds either a personal account or a faculty project account, not
  both. Joining a project suspends the personal account.
- You are responsible for everything done with your credentials. Do not share
  your account.

## 2. Permitted use

Strictly prohibited:

- work unrelated to your NTU study or research, commercial use, crypto-mining
- malicious software, or anything that disrupts other users or the service
- pirated or unlicensed software
- exploiting vulnerabilities or using the cluster in unintended ways
- reading or listing other users' home or project directories without their
  permission (access is logged)
- serving a personal chatbot or inference endpoint from compute nodes

Consequences include loss of access, liability for damages (including claims by
copyright or IP owners) and disciplinary action. Use professional names for
projects and directories.

## 3. Fair use

- **No heavy work on login nodes.** Each user is capped at 3 CPU cores and
  16 GB RAM there; going over kills all your login-node processes. Run anything
  heavy, even without GPUs, as a Slurm job.
- **No hoarding.** Request only what your job uses and release it when done.
  Do not hold idle allocations to reserve GPUs. Batch jobs must actively use
  their GPUs; idle jobs are audited and repeated cases lose GPU access.
- **Redirect scratch and caches** to a project directory before installing or
  downloading anything, as described in the [Storage Guide](storage-guide.md).
  This is required.
- Unusually high usage may be audited.

## 4. Software

- Do not rely on system packages; they change without notice. Use Lmod modules
  for compilers and libraries, and your own Conda environments for Python.
  Experienced users may use containers.
- There is no `sudo`. If your home environment breaks, we reset it rather than
  debug it.
- MATLAB is not provided (licensing). TensorFlow can run but is not supported
  by us.
- Missing software: email us its name and version.

## 5. AI agents

AI coding agents (Claude Code, Codex, Cursor, etc.) are allowed:

- Run them on your own device and let them connect over SSH. Login-node limits
  make IDE backends slow, and an agent that searches your whole home directory
  can hang.
- Give your agent [skill.md](skill.md) at the start of each session.
- You are responsible for everything your agent does, including deleted data,
  permission changes, resource misuse and any ban it triggers. We do not
  support agent installation, network or permission problems.

## 6. Data

- **Nothing is backed up.** Keep your own copies of anything important. Data is
  unreachable while the cluster is down.
- Your files are private unless you share them, but admins and your approver
  (supervisor or course coordinator) may access them for troubleshooting,
  auditing or compliance.
- Data is deleted after 6 months without a login (after a reminder), or when
  your approved usage period ends (e.g. end of semester for course accounts).
- Do not make home or project directories world-readable or writable. You are
  liable for leaks or loss caused by your own permissions; check with `ls -la`.

## 7. Availability

- The cluster is free and run best-effort by a small team. There is no uptime
  guarantee or 24/7 monitoring; jobs may be killed unexpectedly.
- Scheduled maintenance is announced by email, usually 2–3 days ahead. Jobs
  still running when it starts may be killed.

## 8. Support

We support the cluster, not your code: we help when something that works
elsewhere fails here, not with your code's logic or dependencies.

| Request | Response |
|---|---|
| Cluster faults (Slurm down, GPU errors) | As soon as possible |
| Service requests (password reset, reactivation) | Up to 3 working days, best effort |
| Requests against these terms (more resources, priority) | Declined; escalated if repeated |

Before writing to us, check the guides and the login message for known issues.
Email the address that sent your login details, not an admin's personal
contact, and include:

1. the command you ran and its full output (a screenshot is fine), the node
   name from your prompt, and what you already tried;
2. what you expected to happen.

Requests without these details, or answered by the guides, may not get a
detailed reply. Keep all communication professional.

## 9. Disclaimer

THE CLUSTER IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE CLUSTER OR THE USE OR OTHER DEALINGS IN THE CLUSTER.
