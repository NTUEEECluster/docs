# Login Guide

## Pre-requisites

To login to the cluster, you will need:
- Your username (typically same as front part of your NTU email, all lower-case)
- Your default password
- IP to our login node

Please reach out if your application is approved but you are missing any of the
above.

You must also be connected to NTUSECURE or
[NTU VPN](https://vpngate-student.ntu.edu.sg). The cluster is not accessible
outside NTU.

## Logging In

You can SSH into the cluster by typing in the following (do not include the $)
command. An example output has been provided.

```
$ ssh <user>@<ip>  # e.g. ssh example@127.0.0.1
The authenticity of host '127.0.0.1 (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:AhYlWQBTsN/4GAzYTVTiZzrVhPhcurFMu1sBMglqvdM.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

You are advised to copy and paste the following fingerprint for the prompt.
```
SHA256:AhYlWQBTsN/4GAzYTVTiZzrVhPhcurFMu1sBMglqvdM
```

You should then see something similar to:
```
Node: login-3

If you encounter errors, please send the commands you used and the output
(including this message) to <email>.
(example@127.0.0.1) Password:
```

Type in the default password that you have received. You will not see any dots
as you type your password in, this is expected.

You will be prompted for your current password. **Type the default password
again**. After that, you may type your new password twice to finalize the
changing of password.

For full posterity, here is an example of how this may look like upon
successfully logging in:
```
(example@127.0.0.1) Password: <type default password once>
Password expired. Change your password now.
(example@127.0.0.1) Current Password: <type default password twice>
(example@127.0.0.1) New password: <type new password once>
(example@127.0.0.1) Retype new password: <type new password twice>

Cluster02

Message from Cluster Admin (2025-07-31):
  ...

example@login-1:~$
```
