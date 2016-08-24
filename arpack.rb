class Arpack < Formula
  desc "Routines to solve large scale eigenvalue problems"
  homepage "https://github.com/opencollab/arpack-ng"
  url "https://github.com/opencollab/arpack-ng/archive/3.4.0.tar.gz"
  sha256 "69e9fa08bacb2475e636da05a6c222b17c67f1ebeab3793762062248dd9d842f"
  head "https://github.com/opencollab/arpack-ng.git"

  bottle do
    rebuild 1
    sha256 "1dc2e654743752805c212f8c624b4392891176ff216d633daf4d44a97128a0dc" => :sierra
    sha256 "ece580b9a167720f57d13c16fa452ff1583eda615fbcacfd25afe03c801565b5" => :el_capitan
    sha256 "37882bb51410da6602c2660f894de3adcbf7b1c24d82b73c25aafe9a9776fbbd" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on :fortran
  depends_on :mpi => [:optional, :f77]
  depends_on "openblas" => OS.mac? ? :optional : :recommended
  depends_on "veclibfort" if build.without?("openblas") && OS.mac?

  # to be removed at next update
  patch :DATA

  def install
    ENV.m64 if MacOS.prefer_64_bit?
    so = OS.mac? ? "dylib" : "so"

    cmake_args = %w[-DEXAMPLES=ON -DBUILD_SHARED_LIBS=ON]
    if build.with? "mpi"
      cmake_args << "-DMPI=ON"
      cmake_args << "-DCMAKE_Fortran_COMPILER=#{ENV["MPIF77"]}"
    end
    if build.with? "openblas"
      cmake_args << "-DBLAS_openblas_LIBRARY=#{Formula["openblas"].opt_lib}/libopenblas.#{so}"
      cmake_args << "-DLAPACK_openblas_LIBRARY=#{Formula["openblas"].opt_lib}/libopenblas.#{so}"
    elsif OS.mac?
      cmake_args << "-DBLAS_Accelerate_LIBRARY=#{Formula["veclibfort"].opt_lib}/libvecLibFort.#{so}"
      cmake_args << "-DLAPACK_Accelerate_LIBRARY=#{Formula["veclibfort"].opt_lib}/libvecLibFort.#{so}"
    end

    mkdir "build" do
      system "cmake", "..", *(cmake_args + std_cmake_args)
      system "make"
      system "make", "check"
      system "make", "install"
      pkgshare.install "EXAMPLES"
    end
  end

  test do
    if build.with? "mpi"
      (pkgshare/"EXAMPLES/parpack").children.each do |slv|
        system "mpirun", "-np", "4", slv
      end
    else
      (pkgshare/"EXAMPLES/simple").children.each do |slv|
        system slv
      end
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 607d221..64ad291 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -118,6 +118,7 @@ if (MPI)
                         ${parpackutil_STAT_SRCS})
 
     target_link_libraries(parpack ${MPI_Fortran_LIBRARIES})
+    target_link_libraries(parpack arpack)
     set_target_properties(parpack PROPERTIES OUTPUT_NAME parpack${LIBSUFFIX})
 endif ()
 
@@ -389,3 +390,15 @@ target_link_libraries(bug_1323 arpack ${BLAS_LIBRARIES} ${LAPACK_LIBRARIES})
 add_test(bug_1323 Tests/bug_1323)
 
 add_dependencies(check dnsimp_test bug_1315_single bug_1315_double bug_1323)
+
+install(TARGETS arpack
+  ARCHIVE  DESTINATION lib
+  LIBRARY  DESTINATION lib
+  RUNTIME  DESTINATION bin)
+
+if (MPI)
+  install(TARGETS parpack
+    ARCHIVE  DESTINATION lib
+    LIBRARY  DESTINATION lib
+    RUNTIME  DESTINATION bin)
+endif()

