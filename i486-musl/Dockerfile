# syntax=docker/dockerfile:1
FROM gentoo/portage:latest AS portage
FROM gentoo/stage3:musl

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN mkdir -p /opt
COPY build-seed.sh build-kernel.sh /opt/
COPY kernel /opt/kernel

RUN emerge -qv sys-devel/crossdev app-eselect/eselect-repository
RUN eselect repository create crossdev
RUN crossdev -s4 -t i486-unknown-linux-musl
