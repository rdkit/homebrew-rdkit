require 'formula'

def with_java
  return ARGV.include?('--with-java')
end

def with_inchi
  return ARGV.include?('--with-inchi')
end

class Rdkit < Formula
  homepage 'http://rdkit.org/'
  url 'https://github.com/rdkit/rdkit/archive/Release_2013_09_2.zip'
  version '2013.09.2'
  head 'https://github.com/rdkit/rdkit.git'
  sha1 '73a843cb0db3eca7774d273f691b7e28d50656d0'

  depends_on 'cmake' => :build
  depends_on 'wget' => :build
  depends_on 'swig'
  depends_on 'boost'
  depends_on 'numpy' => :python

  def options
    [
      ['--with-java', "Build Java wrapper"],
      ['--with-inchi', "Build InChI support"]
    ]
  end

  def install
    # build java wrapper?
    if with_java
      if not File.exists? 'External/java_lib/junit.jar'
        system "mkdir External/java_lib"
        system "curl http://cloud.github.com/downloads/KentBeck/junit/junit-4.10.jar -o External/java_lib/junit.jar"
      end
    end
    # build inchi support?
    if with_inchi
      system "cd External/INCHI-API; bash download-inchi.sh"
    end

    args = std_cmake_parameters.split
    args << '-DRDK_INSTALL_INTREE=OFF'
    args << '-DRDK_INSTALL_STATIC_LIBS=OFF'
    args << '-DRDK_BUILD_CPP_TESTS=OFF'

    args << '-DRDK_BUILD_SWIG_WRAPPERS=ON' if with_java
    args << '-DRDK_BUILD_INCHI_SUPPORT=ON' if with_inchi

    # The CMake `FindPythonLibs` Module does not do a good job of finding the
    # correct Python libraries to link to, so we help it out (until CMake is
    # fixed). This code was cribbed from the opencv formula, which took it from
    # the VTK formula. It uses the output from `python-config`.
    which_python = "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
    python_prefix = `python-config --prefix`.strip
    # Python is actually a library. The libpythonX.Y.dylib points to this lib, too.
    if File.exist? "#{python_prefix}/Python"
      # Python was compiled with --framework:
      args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
      args << "-DPYTHON_INCLUDE_DIR='#{python_prefix}/Headers'"
    else
      python_lib = "#{python_prefix}/lib/lib#{which_python}"
      if File.exists? "#{python_lib}.a"
        args << "-DPYTHON_LIBRARY='#{python_lib}.a'"
      else
        args << "-DPYTHON_LIBRARY='#{python_lib}.dylib'"
      end
      args << "-DPYTHON_INCLUDE_DIR='#{python_prefix}/include/#{which_python}'"
    end

    args << '.'
    system "cmake", *args
    ENV.j1
    system "make"
    system "make install"
    # Remove the ghost .cmake files which will cause a warning if we install them to 'lib'
    rm_f Dir["#{lib}/*.cmake"]
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
