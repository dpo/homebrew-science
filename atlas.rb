class Atlas < Formula
  desc "Automatically Tuned Linear Algebra Software"
  homepage "http://math-atlas.sourceforge.net"
  url "https://sourceforge.net/projects/math-atlas/files/Stable/3.10.3/atlas3.10.3.tar.bz2"
  sha256 "2688eb733a6c5f78a18ef32144039adcd62fabce66f2eb51dd59dde806a6d2b7"

  devel do
    url "https://sourceforge.net/projects/math-atlas/files/Developer%20%28unstable%29/3.11.38/atlas3.11.38.tar.bz2"
    sha256 "95ba430e959a3a9f209a0876019355550ea2ef181f7e95f87158f421eacda5d2"
  end

  fails_with :clang
  keg_only :provided_by_osx

  option "without-test", "skip build-time tests (not recommended)"

  depends_on :fortran
  depends_on "binutils"

  resource "lapack" do
    url "http://www.netlib.org/lapack/lapack-3.6.0.tgz"
    sha256 "a9a0082c918fe14e377bbd570057616768dca76cbdc713457d8199aaa233ffc3"
  end

  def install
    ENV.deparallelize
    lapack = resource("lapack").fetch
    args = ["--prefix=#{prefix}",
            "--shared",
            "-b", "64",
            "--cc=#{ENV["CC"]}",
            "--with-netlib-lapack-tarfile=#{lapack}"
          ]

    mkdir "build" do
      system "../configure", *args
      system "make"
      if build.with? "test"
        system "make", "check"
        system "make", "ptcheck"
        system "make", "time"
      end
      system "make", "install"
      cd "lib" do
        system "make", "shared"
        system "make", "ptshared"
      end unless OS.mac? # currently broken on OSX
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <cblas.h>
      #include <stdio.h>

      int main(void) {
        int i=0;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);

        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcblas", "-latlas", "-o", "test"
    system "./test"
  end
end
