# Storage Manager Usage

As we have multiple tiers of storage, we manage your storage space differently.
Please see the details below.

This document only covers the `/projects` directory. For a more holistic view,
see [here](cluster.md#Directories).

## Storage Manager (`storagemgr`)

- Running `storagemgr` in your terminal to invoke the **interactive storage
  manager UI**.
- Through this UI, you can request **additional project directories** with
  higher disk quotas.
- Based on your **account type**, storage manager will display your total disk
  quota.
- Your overall quota is mainly determined by the amount of actual storage we
  have. We will attempt to provide more storage if we have more storage. Please
  discuss with your supervisor to contribute storage for more quota should you
  need more.
- Your project directories always appears under `/projects`.

> **NOTE:** It is `/projects`, not `projects`.

## Examples

If your quota on HDD storage is **5.0 TB**, you can either:
- Request **1 project directory** that uses all 5.0 TB,
  *or*
- Create **5 project directories**, each with a 1.0 TB quota.
- You need to define your own uniquely named project directory. Duplicated name
  will result in failure to create your project directories.

## Naming Rules for Projects

- `storagemgr` enforces alphanumeric and hyphens for folder names.
- **Do not** use NSFW or offensive words.
  Violations will result in a **direct and immediate ban**.
- Use a **unique and identifiable name**.
  This is so you don’t forget which folder is yours. `storagemgr` will only
  display the top 5 largest folders that you have.
