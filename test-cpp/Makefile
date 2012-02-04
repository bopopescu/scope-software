INCLUDE=-Iinc/ -I/usr/include/libusb-1.0/
LIBS=-lusb-1.0

CXX=g++
CXXFLAGS=-Wall -Werror

scope: main.o scopev1.o v1format.o
	${CXX} ${CXXFLAGS} -o scope main.o scopev1.o v1format.o ${INCLUDE} ${LIBDIRS} ${LIBS}

scopev1.o: src/scopev1.cpp
	${CXX} ${CXXFLAGS} -c src/scopev1.cpp ${INCLUDE} ${LIBDIRS} ${LIBS}

v1format.o: src/v1format.cpp
	${CXX} ${CXXFLAGS} -c src/v1format.cpp ${INCLUDE} ${LIBDIRS} ${LIBS}

main.o: src/main.cpp
	${CXX} ${CXXFLAGS} -c src/main.cpp ${INCLUDE} ${LIBDIRS} ${LIBS}

.PHONY: clean
clean:
	rm -f *.o scope
