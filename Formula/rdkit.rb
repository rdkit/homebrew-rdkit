require 'formula'

class Rdkit < Formula
  homepage "http://rdkit.org/"
  url "https://github.com/rdkit/rdkit/archive/Release_2016_03_1.tar.gz"
  sha256 "c0ab786ba745bb355141875e6b7fcc94a55cb8709fdc3508e38575b228f668f1"

  head do
    url 'https://github.com/rdkit/rdkit.git'
  end

  option 'with-java', 'Build Java wrapper'
  option 'with-inchi', 'Build with InChI support'
  option 'with-postgresql', 'Build with PostgreSQL database cartridge'
  option 'with-avalon', 'Build with Avalon support'
  option "with-pycairo", "Build with py2cairo/py3cairo support"

  depends_on 'cmake' => :build
  depends_on 'swig' => :build if build.with? 'java'
  depends_on 'boost'
  depends_on :python3 => :optional
  depends_on :postgresql => :optional

  # Different dependencies if building for python3
  if build.with? "python3"
    depends_on "boost-python" => "with-python3"
    depends_on "py3cairo" if build.with? "pycairo"
  else
    depends_on :python
    depends_on "boost-python"
    depends_on "numpy" => :python
    depends_on "py2cairo" if build.with? "pycairo"
  end

  def install
    args = std_cmake_parameters.split

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

    args << "-DRDK_INSTALL_INTREE=OFF"
    args << "-DRDK_BUILD_AVALON_SUPPORT=ON" if build.with? "avalon"
    args << "-DRDK_BUILD_INCHI_SUPPORT=ON" if build.with? "inchi"
    args << '-DRDK_BUILD_CPP_TESTS=OFF'
    args << '-DRDK_INSTALL_STATIC_LIBS=OFF' unless build.with? 'postgresql'

    # Get Python location
    python_executable = if build.with? "python3" then `which python3`.strip else `which python`.strip end
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
    return <<-EOS.undent
    You may need to add RDBASE to your environment variables.
    For Bash, put something like this in your $HOME/.bashrc

      export RDBASE=#{HOMEBREW_PREFIX}/share/RDKit

    EOS
  end
end
