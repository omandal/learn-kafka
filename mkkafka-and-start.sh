#!/bin/bash

# Book: Kafka in Action - Scott, Gamov, Klein (2021)


main() {
    delete_all
    mknetwork
    mktemplate
    mkzooker
    kafka_hostadd ks1 0
    kafka_hostadd ks2 1
    kafka_hostadd ks3 2

    docker run --network kafka -itd --name work -h work kafka bash
    (
    cd
    tar cfz __a.tgz .ssh
    docker cp __a.tgz work:/home/om/a.tgz
    rm -f __a.tgz
    )
    cat <<'EOF' | docker exec -i work su - om -c bash -
cd
sudo chown om:om a.tgz
tar xfz a.tgz
rm -f a.tgz

mkdir sb
cd sb
git clone git@github.com:omandal/learn-kafka.git
EOF
    echo
    echo
    echo 'docker exec -it work su - om'
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

mkzooker() {

    docker rm -f zooker >/dev/null 2>&1
    docker run --network kafka -itd --name zooker -h zooker kafka bash

    # start zookeeper
    cat <<'EOF' | docker exec -i zooker su - om -c bash -
sudo mkdir -p /opt/kafka/logs
sudo chown -R om:om /opt/kafka/logs
tmux new-session -s zook -d '/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties'
# that should run on port 2181
EOF
}

kafka_hostadd() {
    local hostname="$1"
    local brokerid="$2"
    docker rm -f $hostname >/dev/null 2>&1
    docker run --network kafka -itd --name $hostname -h $hostname kafka bash

    cat <<'EOF' | sed 's/__BROKER_ID__/'"$brokerid"'/' | docker exec -i $hostname su - om -c bash -
sudo mkdir -p /opt/kafka/logs
sudo chown -R om:om /opt/kafka/logs

rm -rf ~/kinaction
mkdir ~/kinaction

cd ~/kinaction
egrep -v '^broker.id=|^zookeeper.connect=|^log.dirs=' </opt/kafka/config/server.properties >server.properties
cat <<'_EOF' >>server.properties
broker.id=__BROKER_ID__
zookeeper.connect=zooker:2181
log.dirs=/home/om/kinaction/kafka-logs
_EOF

tmux new-session -s kafka -d '/opt/kafka/bin/kafka-server-start.sh ./server.properties'

EOF

}

main
