FROM ubuntu:latest

ENV TZ="America/Chicago"
RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update
RUN apt-get install -y aptitude magic-wormhole vim build-essential git man-db sudo net-tools
RUN apt-get install -y postgresql postgresql-plperl-14 postgresql-server-dev-14 \
     postgresql-plpython3-14 postgis pgxnclient
RUN apt-get install -y mlocate
WORKDIR /root
RUN git clone https://github.com/arkhipov/temporal_tables.git
WORKDIR /root/temporal_tables
RUN make
RUN make install
COPY pg_hba.conf /etc/postgresql/14/main
COPY postgresql.conf /etc/postgresql/14/main
RUN chown postgres:postgres /etc/postgresql/14/main/pg_hba.conf /etc/postgresql/14/main/postgresql.conf
COPY entry_point.sh /root
WORKDIR /root


CMD ["/root/entry_point.sh"]