# Homebrew-rdkit: tap-ready formula for rdkit

First, make sure you Homebrew version is 0.9 or above (you can check your brew version with `brew --version`).

After tapping this repo with

    brew tap edc/homebrew-rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit

If you want to stay on the edge and use the latest and greatest from SVN:

    brew install --HEAD rdkit


### Optional installs

- `--with-java` will install the Java wrapper.
- `--with-inchi` will install the InChI support. It will NOT use system InChI even it is present. Instead, it will always download InChI from http://inchitrust.org.

### Errors you might encounter

- *Unsatisfied dependency: numpy*

Homebrew does not manage Python package dependencies for you. You need to
install `numpy` with `sudo easy_install numpy`.


