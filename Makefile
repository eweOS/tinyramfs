.POSIX:

PREFIX = /usr/local
BINDIR = ${PREFIX}/bin
MANDIR = ${PREFIX}/share/man
LIBDIR = ${PREFIX}/lib

install:
	mkdir -p ${DESTDIR}${BINDIR}
	mkdir -p ${DESTDIR}${LIBDIR}/tinyramfs
	mkdir -p ${DESTDIR}${MANDIR}/man5
	mkdir -p ${DESTDIR}${MANDIR}/man8
	cp -f tinyramfs     ${DESTDIR}${BINDIR}/
	cp -f lib/init.sh   ${DESTDIR}${LIBDIR}/tinyramfs/
	cp -f lib/helper.sh ${DESTDIR}${LIBDIR}/tinyramfs/
	cp -f lib/common.sh ${DESTDIR}${LIBDIR}/tinyramfs/
	cp -R hook          ${DESTDIR}${LIBDIR}/tinyramfs/hook.d

uninstall:
	rm -f  ${DESTDIR}${BINDIR}/tinyramfs
	rm -f  ${DESTDIR}${MANDIR}/man5/tinyramfs.5
	rm -f  ${DESTDIR}${MANDIR}/man8/tinyramfs.8
	rm -rf ${DESTDIR}${LIBDIR}/tinyramfs

lint:
	shellcheck hook/*/* lib/* test/*.test tinyramfs *.conf

check:
	(cd test && ${MAKE})

doc:
	scdoc < doc/tinyramfs.5.scd > doc/tinyramfs.5
	scdoc < doc/tinyramfs.8.scd > doc/tinyramfs.8

.PHONY: install uninstall doc
