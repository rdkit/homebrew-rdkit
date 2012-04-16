# Homebrew-rdkit: tap-ready formula for rdkit

After tapping this repo with

    brew tap edc/rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit

If you want to stay on the edge and use the latest and greatest from SVN:

    brew install --head rdkit

### Errors you might encounter

- *Unsatisfied dependency: numpy*

Homebrew does not manage Python package dependencies for you. You need to
install `numpy` with `sudo easy_install numpy`.


