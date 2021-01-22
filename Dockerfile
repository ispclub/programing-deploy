FROM ubuntu:18.04

RUN apt-get update --fix-missing

RUN apt -y install socat

RUN groupadd ctf

RUN mkdir /chall

COPY ./dir /chall

RUN useradd -G ctf --home=/chall revuser
RUN useradd -G ctf --home=/chall revflag

RUN chown revflag:revflag /chall/flag.txt
RUN chown revflag:revflag /chall/ELF

RUN chmod 4755 /chall/ELF
RUN chmod 444 /chall/flag.txt

EXPOSE 8289

CMD ["su", "-c", "exec socat TCP-LISTEN:8289,reuseaddr,fork EXEC:/chall/ELF,stderr", "-", "revuser"]