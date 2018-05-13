SYS_ARCH = $(shell sh -c 'uname -m 2>/dev/null')
ifeq ($(SYS_ARCH),i686)
MEXSUFFIX = mexglx
MEXARCH = glnx86
endif
ifeq ($(SYS_ARCH),x86_64)
MEXSUFFIX = mexa64
MEXARCH = glnxa64
endif

MATLAB  = /usr/local/MATLAB
MEX = ${MATLAB}/bin/mex
CXX = g++-4.4

CXXFLAGS = -ansi -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC -pthread
CXXOPTIMFLAGS = -O2
LDOPTIMFLAGS = -O2
LDFLAGS = -pthread -shared -Wl,--version-script,${MATLAB}/extern/lib/$(MEXARCH)/mexFunction.map -Wl,--no-undefined ${MATLAB}/sys/os/$(MEXARCH)/libstdc++.so.6

LIBS = -lm
MEXFLAGS = -cxx -v CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" CXXOPTIMFLAGS="$(CXXOPTIMFLAGS)" LDFLAGS="$(LDFLAGS)" LDOPTIMFLAGS="$(LDOPTIMFLAGS)"

all: firmsim_cpp.${MEXSUFFIX}

firmsim_cpp.${MEXSUFFIX}: firmsim.cpp
	$(MEX) $(MEXFLAGS) $(LIBS) firmsim.cpp -o firmsim_cpp.${MEXSUFFIX}
	cp $@ ..

clean:
	rm -f firmsim_cpp.${MEXSUFFIX}

