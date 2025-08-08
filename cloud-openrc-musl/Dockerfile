# syntax=docker/dockerfile:1
FROM gentoo/portage:latest AS portage
FROM gentoo/stage3:musl

ARG TARGETARCH

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

COPY grub /etc/default/grub
COPY inittab /etc/inittab

RUN mkdir -p /opt
COPY emerge.sh /opt/
RUN chmod 755 /opt/emerge.sh
RUN /opt/emerge.sh $TARGETARCH

COPY 10-gentoo-netifrc.cfg /etc/cloud/cloud.cfg.d/10-gentoo-netifrc.cfg
