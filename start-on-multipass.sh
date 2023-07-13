#!/bin/bash

#https://kafka.apache.org/quickstart


mp launch -n kafka -d 20G -m 2G
cat <<'EOF' | mp exec kafka bash -
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y install sudo git vim curl tmux
sudo apt-get -y install openjdk-17-jdk-headless
sudo useradd -s /bin/bash -m om
echo 'om ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/om
EOF


mkdir -p ~/bin
cd ~/bin
curl -sL -o kafka.tgz 'https://dlcdn.apache.org/kafka/3.4.0/kafka_2.13-3.4.0.tgz'
tar xfz kafka.tgz
cd kafka_2.13-3.4.0

Two services
    On one window
    bin/zookeeper-server-start.sh config/zookeeper.properties

    On another window
    bin/kafka-server-start.sh config/server.properties


Create a topic
    bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
    bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092

Write something into a topic
    bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092


Read the topic
    bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092


