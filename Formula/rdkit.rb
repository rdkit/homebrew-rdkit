require 'formula'

class Rdkit < Formula
  url 'http://sourceforge.net/projects/rdkit/files/rdkit/Q1_2012/RDKit_2012_03_1.tgz'
  head 'https://rdkit.svn.sourceforge.net/svnroot/rdkit', :using=> :svn
  homepage 'http://rdkit.org'
  md5 'bec0098965bd6b66f74f87dd6172213a'

  depends_on 'cmake' => :build
  depends_on 'swig'
  depends_on 'boost'
  depends_on 'numpy' => :python

  def install
    if not File.exists? 'External/java_lib/junit.jar'
      system "mkdir External/java_lib"
      system "curl http://cloud.github.com/downloads/KentBeck/junit/junit-4.10.jar -o External/java_lib/junit.jar"
    end
    system "cmake . #{std_cmake_parameters} -DRDK_INSTALL_INTREE=OFF -DRDK_BUILD_SWIG_WRAPPERS=ON -DRDK_INSTALL_STATIC_LIBS=OFF"
    ENV.j1
    system "make"
    system "make install"
  end

  def caveats
    python_lib = `python --version 2>&1| sed -e 's/Python \\([0-9]\\.[0-9]\\)\\.[0-9]/python\\1/g'`.strip
	  
    return <<-EOS.undent
    You still have to add RDBASE to your environment variables and update
    PYTHONPATH.

    For Bash, put something like this in your $HOME/.bashrc

      export RDBASE=#{HOMEBREW_PREFIX}/share/RDKit
      export PYTHONPATH=$PYTHONPATH:#{HOMEBREW_PREFIX}/lib/#{python_lib}/site-packages

    EOS
  end
end
