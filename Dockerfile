# syntax=docker/dockerfile:1
FROM gentoo/portage:latest AS portage
FROM gentoo/stage3:musl

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN mkdir -p /opt
COPY build-seed.sh build-kernel.sh /opt/
COPY kernel/ /opt/
RUN chmod 755 /opt/build-seed.sh

RUN emerge -v sys-devel/crossdev app-eselect/eselect-repository