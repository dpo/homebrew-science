class Openbr < Formula
  desc "Open Source Biometrics, Face Recognition"
  homepage "http://www.openbiometrics.org/"
  url "https://github.com/biometrics/openbr.git"
  version "0.5.0"

  option "with-check", "Run build-time tests (time consuming)"

  depends_on "cmake" => :build
  depends_on "qt5"
  depends_on "opencv"
  depends_on "eigen"

  def install
    mkdir "build" do
      system "cmake", "..", "-DCMAKE_BUILD_TYPE=Release", *std_cmake_args
      system "make"
    end

    if build.with? "check"
      cd "scripts" do
        system "./downloadDatasets.sh"
      end
      system "make", "test"
    end

    cd "build" do
      system "make", "install"
    end
  end

  test do
    system "#{bin}/br", "-version"
  end
end
