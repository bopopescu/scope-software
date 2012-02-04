INCLUDE=-Iinc/ -I/usr/include/libusb-1.0/
LIBS=

scope: main.o scopev1.o v1format.o
	g++ -o scope main.o scopev1.o v1format.o ${INCLUDE} ${LIBS}

scopev1.o: src/scopev1.cpp
	g++ -o scopev1.o src/scopev1.cpp ${INCLUDE} ${LIBS}

v1format.o: src/v1format.cpp
	g++ -o v1format.o src/v1format.cpp ${INCLUDE} ${LIBS}

main.o: src/main.cpp
	g++ -o main.o src/main.cpp ${INCLUDE} ${LIBS}
