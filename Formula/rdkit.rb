require 'formula'

class Rdkit < Formula
  homepage "http://rdkit.org/"
  url "https://github.com/rdkit/rdkit/archive/Release_2017_09_3.tar.gz"
  sha256 "6a4d9e9eb0ca06cbcdc20505f0c6ea0b1167b4dcdf7d1185871ba16ce701a5f4"

  head do
    url 'https://github.com/rdkit/rdkit.git'
  end

  option 'with-java', 'Build Java wrapper'
  option 'with-inchi', 'Build with InChI support'
  option 'with-postgresql', 'Build with PostgreSQL database cartridge'
  option 'with-avalon', 'Build with Avalon support'
  option "with-pycairo", "Build with py2cairo/py3cairo support"
  option "without-numpy", "Use your own numpy instead of Homebrew's numpy"

  depends_on "cmake" => :build
  depends_on "swig" => :build if build.with? 'java'
  depends_on "boost"
  depends_on "eigen" => :recommended
  depends_on "python3" => :optional
  depends_on "postgresql" => :optional

  # only building for python3
  depends_on "boost-python3"
  depends_on "numpy" => [:recommended, "with-python3"]
  depends_on "py3cairo" if build.with? "pycairo"
  
  def install
    ENV['CXXFLAGS'] = '-std=c++11 -stdlib=libc++ -Wno-parentheses -Wno-logical-op-parentheses -Wno-format'
    ENV['CFLAGS'] = '-Wno-parentheses -Wno-logical-op-parentheses -Wno-format'

    args = std_cmake_args
    args << "-DRDK_INSTALL_INTREE=OFF"
    args << "-DRDK_BUILD_SWIG_WRAPPERS=ON" if build.with? "java"
    args << "-DRDK_BUILD_AVALON_SUPPORT=ON" if build.with? "avalon"
    args << "-DRDK_BUILD_PGSQL=ON" if build.with? "postgresql"
    args << "-DRDK_BUILD_INCHI_SUPPORT=ON" if build.with? "inchi"
    args << '-DRDK_BUILD_CPP_TESTS=OFF'
    args << '-DRDK_INSTALL_STATIC_LIBS=OFF' unless build.with? 'postgresql'

    # Get Python location
    python_executable = `which python3`.strip
    python_prefix = %x(#{python_executable} -c 'import sys;print(sys.prefix)').chomp
    python_include = %x(#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))').chomp
    python_version = "python" + %x(#{python_executable} -c 'import sys;print(sys.version[:3])').chomp
    args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
    
    # Get numpy location
    numpy_include = %x(#{python_executable} -c 'import numpy;print(numpy.get_include())').chomp
    args << "-DPYTHON_NUMPY_INCLUDE_PATH='#{numpy_include}'"

    args << '.'
    system "cmake", *args
    system "make", "-j#{ENV.make_jobs}"
    system "make install"

    # Remove the ghost .cmake files which will cause a warning if we install them to 'lib'
    rm_f Dir["#{lib}/*.cmake"]

    # Install java files
    if build.with? "java"
      libexec.install "Code/JavaWrappers/gmwrapper/org.RDKit.jar"
      libexec.install "Code/JavaWrappers/gmwrapper/org.RDKitDoc.jar"
      lib.install "Code/JavaWrappers/gmwrapper/libGraphMolWrap.jnilib"
    end

    # Install postgresql files
    if build.with? "postgresql"
      mv "Code/PgSQL/rdkit/rdkit.sql91.in", "Code/PgSQL/rdkit/rdkit--3.4.sql"
      (share + 'postgresql/extension').install "Code/PgSQL/rdkit/rdkit--3.4.sql"
      (share + 'postgresql/extension').install "Code/PgSQL/rdkit/rdkit.control"
      (lib + 'postgresql').install "Code/PgSQL/rdkit/rdkit.so"
    end
  end

  def caveats
    s = <<-EOS
      You may need to add RDBASE to your environment variables.
      For Bash, put something like this in your $HOME/.bashrc:
        export RDBASE=#{HOMEBREW_PREFIX}/share/RDKit
    EOS
    if build.with? "java"
      s += <<-EOS

        The RDKit Jar file has been installed to:
          #{libexec}/org.RDKit.jar
        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{lib}/libGraphMolWrap.jnilib /Library/Java/Extensions/libGraphMolWrap.jnilib
      EOS
    end
    s
  end
end
