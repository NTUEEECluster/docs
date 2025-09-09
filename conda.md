# Using Conda on the Cluster (with Lmod)

Our cluster uses **Lmod** for managing software environments.  
If you want to use Python packages via **Miniforge3** or **Miniconda3**, you
must follow these steps.

---

## Load Miniforge3 or Miniconda3

First, check what modules are available:

```bash
module avail
```

Then load either Miniforge3 or Miniconda3 via

```bash
module load Miniforge3
```

Do not load both at the same time.

You *HAVE TO* run 
```bash
source activate
```
after you load Miniforge or Miniconda. Then you can see there is a `(base)` in
your shell session.

## Create your environment if you want custom packages

You *HAVE TO* create your own conda environment if you want to install packages
with `pip install` or `conda install`.

By default, you *CANNOT* install anything to the base environment because it is
supposed to be a shared python env for basic python operations.

The command to create your env is `conda create -n env_name python=3.xx`, and
*DO NOT* forget to activate it by `conda activate env_name`. `env_name` is the
name you define! You also need to specify specific python version you want, for
example, 3.10.

## Scope of Support

We do not and will not help you to resolve problems such as package conflicts,
package version mismatch, etc. that are not caused by the cluster's setups.

We provide a guides on
[how to start debugging your code on the cluster](debugging.md), BUT we do not
help you debug any of your applications' specific errors.

Before asking for help, take a close look at your error message and google it or
ask GPT. This is to save both your and our time on trivial questions. If that
fails, check our [troubleshooting guide](troubleshooting.md).
