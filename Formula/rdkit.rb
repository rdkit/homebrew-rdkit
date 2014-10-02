require 'formula'

class Rdkit < Formula
  homepage 'http://rdkit.org/'
  url 'https://github.com/rdkit/rdkit/archive/Release_2014_03_1.tar.gz'
  sha1 '7db855bd78abe13afa3436fded03c7a4449f1b3b'

  # devel do
  #   url 'https://github.com/rdkit/rdkit/archive/Release_2014_03_1beta1.tar.gz'
  #   version '2014.03.1b1'
  # end

  head do
    url 'https://github.com/rdkit/rdkit.git'
  end

  option 'with-java', 'Build Java wrapper'
  option 'with-inchi', 'Build with InChI support'
  option 'with-postgresql', 'Build with PostgreSQL database cartridge'
  option 'with-avalon', 'Build with Avalon support'

  depends_on 'cmake' => :build
  depends_on 'wget' => :build
  depends_on 'swig' => :build
  depends_on 'boost'
  depends_on 'boost-python'
  depends_on 'numpy' => :python
  depends_on :postgresql => :optional

  def install
    args = std_cmake_parameters.split
    args << '-DRDK_INSTALL_INTREE=OFF'
    # build java wrapper?
    if build.with? 'java'
      if not File.exists? 'External/java_lib/junit.jar'
        system "mkdir External/java_lib"
        system "curl http://search.maven.org/remotecontent?filepath=junit/junit/4.11/junit-4.11.jar -o External/java_lib/junit.jar"
      end
      java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
      if File.exist? "#{java_home}/include/jni.h"
        args << "-DJAVA_AWT_INCLUDE_DIRECTORIES=#{java_home}/include"
      elsif File.exist? "/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/jni.h"
        args << "-DJAVA_AWT_INCLUDE_DIRECTORIES=/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/"
        args << "-DJAVA_AWT_LIBRARY_DIRECTORIES=#{java_home}/bundle/Libraries/"
      end
      args << '-DRDK_BUILD_SWIG_WRAPPERS=ON'
    end
    # build inchi support?
    if build.with? 'inchi'
      system "cd External/INCHI-API; bash download-inchi.sh"
      args << '-DRDK_BUILD_INCHI_SUPPORT=ON'
    end
    # build avalon tools?
    if build.with? 'avalon'
      system "curl -L https://downloads.sourceforge.net/project/avalontoolkit/AvalonToolkit_1.1_beta/AvalonToolkit_1.1_beta.source.tar -o External/AvalonTools/avalon.tar"
      system "tar xf External/AvalonTools/avalon.tar -C External/AvalonTools"
      args << '-DRDK_BUILD_AVALON_SUPPORT=ON'
      args << "-DAVALONTOOLS_DIR=#{buildpath}/External/AvalonTools/SourceDistribution"
    end

    args << '-DRDK_BUILD_CPP_TESTS=OFF'
    args << '-DRDK_INSTALL_STATIC_LIBS=OFF' unless build.with? 'postgresql'

    # Get Python location
    python_executable = `which python`.strip
    python_prefix = %x(#{python_executable} -c 'import sys;print(sys.prefix)').chomp
    python_include = %x(#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))').chomp
    python_version = "python" + %x(#{python_executable} -c 'import sys;print(sys.version[:3])').chomp
    args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
    if File.exist? "#{python_prefix}/Python"
      args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
    elsif File.exists? "#{python_prefix}/lib/lib#{python_version}.a"
      args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
    else
      args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.dylib'"
    end

    # Get numpy location
    numpy_include = %x(#{python_executable} -c 'import numpy;print(numpy.get_include())').chomp
    args << "-DPYTHON_NUMPY_INCLUDE_PATH='#{numpy_include}'"

    args << '.'
    system "cmake", *args
    system "make"
    system "make install"
    # Remove the ghost .cmake files which will cause a warning if we install them to 'lib'
    rm_f Dir["#{lib}/*.cmake"]
    if build.with? 'postgresql'
      ENV['RDBASE'] = "#{prefix}"
      ENV.append 'CFLAGS', "-I#{include}/rdkit"
      cd 'Code/PgSQL/rdkit' do
        system "make"
        system "make install"
      end
    end
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
