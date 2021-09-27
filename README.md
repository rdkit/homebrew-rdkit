```
WARNING: this repository is outdated. Please consider using the more recent brew formula
WARNING: to install rdkit. The new formula does not require you to use the rdkit/rdkit tap
WARNING: and installs python bindings.
WARNING: Cf. https://formulae.brew.sh/formula/rdkit#default (brew install rdkit).
```

[![Build status](https://travis-ci.org/rdkit/homebrew-rdkit.svg)](https://travis-ci.org/rdkit/homebrew-rdkit)

# Homebrew-rdkit: tap-ready formula for rdkit

First, make sure you Homebrew version is 0.9 or above (you can check your brew version with `brew --version`).

After tapping this repo with

    brew tap rdkit/rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit --with-python3

If you want to stay on the edge and use the latest and greatest from GitHub:

    brew install --HEAD rdkit --with-python3

### Optional installs

- `--with-python3` will install the Python 3 wrapper.
- `--with-java` will install the Java wrapper.
- `--with-inchi` will install the InChI support. This will download InChI from https://inchi-trust.org if necessary.
- `--with-avalon` will install the Avalon toolkit support. This will download the Avalon Toolkit source.
- `--with-postgresql` will install the PostgreSQL cartridge.
- `--with-pycairo` if you want to draw molecules with Cairo.

### Forcing brew to install rdkit and all its dependencies from scratch

Brew is not a very smart or reliable package manager.
If you encounter any error, you might try the following to force installing
rdkit:

    # backup your brew installed packages list
    brew list --formula > my_brew_packages.txt
    # uninstall all of them
    brew uninstall --force $(cat my_brew_packages.txt)
    # install rdkit from scratch
    brew install rdkit --with-python3

### Errors you might encounter

- *Unsatisfied dependency: numpy*

By default, Homebrew will attempt to install and manage numpy for you, like all other dependencies. You may alternatively install and manage numpy separately, via `pip`:

    pip3 install numpy
    brew install rdkit --with-python3 --without-numpy

- *Fatal Python error: Interpreter not initialized (version mismatch?)*

This indicates that rdkit or one of its dependencies (e.g. boost) was linked
against a different version of Python than the one you are using it with.
Try rebuilding boost from source:

    brew uninstall boost
    brew install boost --build-from-source

If that doesn't fix it, try comparing the output of these three commands:

    python-config --prefix
    find /usr/local/Cellar/rdkit -name rdBase.so -exec otool -L {} \;
    find /usr/local/Cellar/boost -name libboost_python-mt.dylib -exec otool -L {} \;

- *TypeError: No to_python (by-value) converter found for C++ type: boost::shared_ptr<RDKit::ROMol>*

This is likely due to a bug in boost-python v1.60, which has now been patched in the boost homebrew formula. To get the patch, run:

    brew reinstall boost
    brew reinstall rdkit
