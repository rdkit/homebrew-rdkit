# Homebrew-rdkit: tap-ready formula for rdkit

Make sure you Homebrew version is 0.9 and above. After tapping this repo with

    brew tap edc/homebrew-rdkit

You can install [rdkit](http://rdkit.org) with just one line of command:

    brew install rdkit

If you want to stay on the edge and use the latest and greatest from SVN:

    brew install --HEAD rdkit

### Errors you might encounter

- *Unsatisfied dependency: numpy*

Homebrew does not manage Python package dependencies for you. You need to
install `numpy` with `sudo easy_install numpy`.


