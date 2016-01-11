class Plasma < Formula
  desc "Parallel Linear Algebra Software for Multicore Architectures"
  homepage "http://icl.cs.utk.edu/plasma"
  url "http://icl.cs.utk.edu/projectsfiles/plasma/pubs/plasma_2.8.0.tar.gz"
  sha256 "e8758a71ddd02ad1fb57373cfd62fb1b32cebea62ba517484f1adf9f0afb1ddb"

  depends_on "hwloc"
  depends_on :fortran

  resource "lapacke" do
    url "http://icl.cs.utk.edu/projectsfiles/plasma/pubs/lapacke.tgz"
    sha256 "506344e126cf774ff9b7180104f87a580fa938c499179d8747cd97e4d4a543d3"
  end

  def install
    resource("lapacke").stage do
      system "make", "CC=#{ENV.cc}", "LINKER=#{ENV["FC"]}", "LIBS=-llapack -lblas -lm", "RANLIB=true"
      include.install Dir["include/*"]
      lib.install "lapacke.a"
    end

    # ENV.deparallelize
    make_args = %W[
      prefix=#{prefix}
      CC=#{ENV.cc}
      FC=#{ENV["FC"]}
      RANLIB=true
      FFLAGS=#{ENV["FFLAGS"]}
      LIBBLAS=-lblas
      LIBLAPACK=-llapack
      LIBCBLAS=-lcblas
      INCCLAPACK=-I#{include}
      LIBCLAPACK=#{lib}/lapacke.a
      PLASMA_F90=1
    ]

    cp "makes/make.inc.mac", "make.inc"
    system "make", *make_args
    system "false"
  end

  def caveats; <<-EOS.undent
    export VECLIB_MAXIMUM_THREADS=1
    EOS
  end

  test do
    system "false"
  end
end
