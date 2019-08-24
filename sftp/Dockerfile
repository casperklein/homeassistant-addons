FROM	debian:10-slim

ENV	PACKAGES="jq openssh-server"

RUN	apt-get update \
&&	apt-get -y install $PACKAGES \
&&	mkdir /run/sshd \
&&	sed -i 's/\/root/\/mnt/g' /etc/passwd \
&&	ln -s /addons /mnt/addons \
&&	ln -s /backup /mnt/backup \
&&	ln -s /config /mnt/config \
&&	ln -s /share /mnt/share \
&&	ln -s /ssl /mnt/ssl

ADD	sshd_config /etc/ssh/sshd_config
ADD	docker-run.sh /

EXPOSE	22

CMD	/docker-run.sh
