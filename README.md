# Homebrew-rdkit: tap-ready formula for rdkit

First, make sure you Homebrew version is 0.9 or above (you can check your brew version with `brew --version`).

After tapping this repo with

    brew tap rdkit/rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit

If you want to stay on the edge and use the latest and greatest from <del>SVN</del> GitHub:

    brew install --HEAD rdkit


### Optional installs

- `--with-java` will install the Java wrapper.
- `--with-inchi` will install the InChI support. It will NOT use system InChI even it is present. Instead, it will always download InChI from http://inchitrust.org.

### Errors you might encounter

- *Unsatisfied dependency: numpy*

Homebrew does not manage Python package dependencies for you. You need to
install `numpy` with `sudo easy_install numpy`.

- *Fatal Python error: Interpreter not initialized (version mismatch?)*

This indicates that rdkit or one of its dependencies (eg. boost) was linked
against a different version of Python than the one you are using it with.
Try rebuilding boost from source:

    brew uninstall boost
    brew install boost --build-from-source

If that doesn't fix it, try comparing the output of these three commands:

    python-config --prefix
    find /usr/local/Cellar/rdkit -name rdBase.so -exec otool -L {} \;
    find /usr/local/Cellar/boost -name libboost_python-mt.dylib -exec otool -L {} \;
