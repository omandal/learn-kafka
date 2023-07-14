#!/bin/bash

# Book: Kafka in Action - Scott, Gamov, Klein (2021)


main() {
    delete_all
    mknetwork
    mktemplate
    mkmachines
    start_zookeeper
    configure_kafka_hosts
    start_kafka_servers
}

delete_all() {
    docker rm -f zooker
    docker rm -f ks1
    docker rm -f ks2
    docker rm -f ks3
    docker rm -f work
    docker rmi -f kafka
}


mknetwork() {
    docker network list --format json|jq -r '.Name'| docker network list --format json|jq -r '.Name'|grep '^kafka$'
    if [[ $? != 0 ]]; then
        docker network create kafka
    fi
    docker network list --format json|jq -r '.Name'| docker network list --format json|jq -r '.Name'|grep '^kafka$'
    if [[ $? != 0 ]]; then
        echo "Could not create docker network \"kafka\""
        exit 1
    fi
}

mktemplate() {
    docker run --network kafka -itd --name work -h work ubuntu:22.04
    cat <<'EOF' | docker exec -i work bash -
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install sudo git vim curl tmux iputils-ping
apt-get -y install openjdk-17-jdk-headless

mkdir -p /tmp/xx
cd /tmp/xx
curl -sL -o a.tgz https://downloads.apache.org/kafka/3.5.0/kafka_2.13-3.5.0.tgz
tar xfz a.tgz
mv kafka* /opt/kafka
cd /
rm -rf /tmp/xx

useradd -s /bin/bash -m om
echo 'om ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/om
echo 'export PATH=/opt/kafka/bin:$PATH' >>~om/.bashrc
chown -R om:om ~om
EOF

    docker stop work
    docker export work | docker import - kafka
    docker rm -f work
}

mkmachines() {
    docker run --network kafka -itd --name zooker -h zooker kafka bash
    docker run --network kafka -itd --name ks1 -h ks1 kafka bash
    docker run --network kafka -itd --name ks2 -h ks2 kafka bash
    docker run --network kafka -itd --name ks3 -h ks3 kafka bash
    docker run --network kafka -itd --name work -h work kafka bash
}

start_zookeeper() {
    # start zookeeper
    cat <<'EOF' | docker exec -i zooker su - om -c bash -
sudo mkdir -p /opt/kafka/logs
sudo chown -R om:om /opt/kafka/logs
tmux new-session -s zook -d '/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties'
# that should run on port 2181
EOF
}

configure_kafka_hosts() {
    for host in ks1 ks2 ks3; do
        cat <<'EOF' | docker exec -i $host su - om -c bash -
sudo mkdir -p /opt/kafka/logs
sudo chown -R om:om /opt/kafka/logs
rm -rf ~/kinaction
mkdir ~/kinaction
cd ~/kinaction
egrep -v '^broker.id=|^zookeeper.connect=|^log.dirs=' </opt/kafka/config/server.properties >server.properties
EOF
    done

    cat <<'EOF' | docker exec -i ks1 su - om -c bash -
cat <<'_EOF' >>~/kinaction/server.properties
broker.id=0
zookeeper.connect=zooker:2181
log.dirs=/home/om/kinaction/kafka-logs
_EOF
EOF

    cat <<'EOF' | docker exec -i ks2 su - om -c bash -
cat <<'_EOF' >>~/kinaction/server.properties
broker.id=1
zookeeper.connect=zooker:2181
log.dirs=/home/om/kinaction/kafka-logs
_EOF
EOF

    cat <<'EOF' | docker exec -i ks3 su - om -c bash -
cat <<'_EOF' >>~/kinaction/server.properties
broker.id=2
zookeeper.connect=zooker:2181
log.dirs=/home/om/kinaction/kafka-logs
_EOF
EOF

}

start_kafka_servers() {
    for server in ks1 ks2 ks3; do
        cat <<'EOF' | docker exec -i $server su - om -c bash -
cd ~/kinaction
tmux new-session -s kafka -d '/opt/kafka/bin/kafka-server-start.sh ./server.properties'
EOF
    done
}

main
