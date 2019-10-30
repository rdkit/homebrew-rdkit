[![Build status](https://travis-ci.org/rdkit/homebrew-rdkit.svg)](https://travis-ci.org/rdkit/homebrew-rdkit)

# Homebrew-rdkit: tap-ready formula for rdkit

First, make sure you Homebrew version is 0.9 or above (you can check your brew version with `brew --version`).

After tapping this repo with

    brew tap rdkit/rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit

If you want to stay on the edge and use the latest and greatest from GitHub:

    brew install --HEAD rdkit


### Optional installs

- `--with-python3` will install RDkit under the Python3 (By default, the RDkit is installed under Python2)
- `--with-java` will install the Java wrapper.
- `--with-inchi` will install the InChI support. This will download InChI from http://inchitrust.org if necessary.
- `--with-avalon` will install the Avalon toolkit support. This will download the Avalon Toolkit source. 
- `--with-postgresql` will install the PostgreSQL cartridge.

### Errors you might encounter

- *Unsatisfied dependency: numpy*

By default, Homebrew will attempt to install and manage numpy for you, like all other dependencies. You may alternatively install and manage numpy separately, via `pip`. However, when installing rdkit with python 3, a pip-installed numpy for python 2 can prevent homebrew properly installing numpy for python 3. To solve this, make sure you use `pip` in both python 2 and 3:

    pip3 install numpy
    brew install rdkit --with-python3
