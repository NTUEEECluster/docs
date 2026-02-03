# Loading Software with Lmod (for Compiling Packages)

We use **Lmod** to provide compilers, libraries, and tools. If you plan to
compile software from source, load the correct toolchain with Lmod first.

## What is CUDA, why do I need it?

CUDA is NVIDIA's GPU computing platform and toolkit. In many open-source
repositories, CUDA is required to compile custom GPU operators or extensions.
Whether you need CUDA is highly case-by-case and depends on how the package is
built and distributed.

For example, PyTorch wheels often bundle the CUDA runtime and can run without a
system CUDA toolkit installed (as long as the driver is compatible). Other
frameworks, such as TensorFlow, may rely on a locally installed CUDA toolkit
and specific versions of CUDA and cuDNN. If a package expects a system CUDA
toolchain, you must load the appropriate CUDA module before compiling or
running it.

You need to figure out the correct toolchain for your package. The cluster team
can only supply as many software stacks as possible via Lmod.

## Find available modules

The available module list can be queried via:

```bash
module avail
```

Some modules are only visible via search:

```bash
module spider <name>
```

To see dependencies and environment changes:

```bash
module show <name>
```

## Load a build toolchain

Common modules for compiling:

```bash
module load GCCcore
module load CMake
module load CUDA   # only if your build needs CUDA
```

Note: specify versions instead of leaving them blank (e.g., `module load GCCcore/12.2.0`).

Check what is currently loaded:

```bash
module list
```

If your environment gets messy, reset and reload what you need:

```bash
module purge
```

## Typical compile workflow

1) Load your toolchain modules.
2) Configure the build.
3) Build and install into your own directory (no `sudo`).

## Notes

- Modules are locally compiled and often have dependencies. If a build fails
  because of missing headers or libraries, check `module show` and load the
  required dependencies (e.g., `GCCcore`).
- If a required module is missing, email the admins with the exact software
  name and version you need.
