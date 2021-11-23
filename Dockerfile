#CREDIT TO Salvador Abreu for the initial version of this dockerfile
FROM debian:bullseye-slim

ENV WORKDIR=/root
WORKDIR ${WORKDIR}
ENV SAVEDIR=${WORKDIR}/data

ENV LOGTALKHOME=/usr/share/logtalk
ENV LOGTALKUSER=${WORKDIR}/logtalk
ENV PATH=\
$PATH:\
${SAVEDIR}:\
${SAVEDIR}.init:\
${LOGTALKHOME}/tools/diagrams:\
${LOGTALKHOME}/tools/lgtdoc/xml:\
${LOGTALKHOME}/scripts:${LOGTALKHOME}/integration:

ENV MANPATH=${MANPATH}:${LOGTALKHOME}/man

ENV LGTVERS=3.47.0-1
ENV LGTDEB=logtalk_${LGTVERS}_all.deb

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends swi-prolog-nox
RUN apt-get install -y wget

RUN [ -e ${WORKDIR}/${LGTDEB} ] || wget -q https://logtalk.org/files/${LGTDEB} 
RUN dpkg -i ${WORKDIR}/${LGTDEB}
RUN rm -f ${WORKDIR}/${LGTDEB}

RUN useradd -ms /bin/bash logtalk

COPY src/ ${WORKDIR}/

COPY ./init.pl ${WORKDIR}/.config/swi-prolog/
COPY ./settings.lgt ${LOGTALKUSER}/

RUN chmod a+x ${WORKDIR}/daemon.sh

RUN touch httpd.log
RUN chown logtalk:logtalk ${WORKDIR}/httpd.log
RUN chown logtalk:logtalk ${WORKDIR}/.lgt_tmp

RUN swilgt -g "halt"

RUN chown logtalk:logtalk ${WORKDIR}/logtalk

ENTRYPOINT ["swilgt"]
CMD ["/root/run.lgt"]


