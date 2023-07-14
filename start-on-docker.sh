export PATH=.:$PATH
mkkafka-and-start.sh
export KAFKAS=ks1:9092
topic list
topic create :q



docker exec -it work su - om

om@work:~$ kafka-topics.sh --create --bootstrap-server ks2:9092 --topic hello
Created topic hello.

om@work:~$ kafka-topics.sh --create --bootstrap-server ks3:9092 --topic hello
Error while executing topic command : Topic 'hello' already exists.
[2023-07-14 04:08:15,840] ERROR org.apache.kafka.common.errors.TopicExistsException: Topic 'hello' already exists.
 (kafka.admin.TopicCommand$)
om@work:~$


om@work:~$ kafka-topics.sh --list --bootstrap-server ks3:9092
hello

om@work:~$ kafka-topics.sh --bootstrap-server ks1:9092 --delete --topic hello


om@work:~$ kafka-topics.sh --bootstrap-server ks1:9092 --create --topic kinaction_helloworld --partitions 3 --replication-factor 3
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic kinaction_helloworld.
om@work:~$

kafka-topics.sh --bootstrap-server ks1:9092 --describe --topic kinaction_helloworld

om@work:~$ kafka-topics.sh --bootstrap-server ks1:9092 --describe --topic kinaction_helloworld
Topic: kinaction_helloworld	TopicId: Jf7r4twVQEqjNoBesGM0eA	PartitionCount: 3	ReplicationFactor: 3	Configs:
	Topic: kinaction_helloworld	Partition: 0	Leader: 1	Replicas: 1,0,2	Isr: 1,0,2
	Topic: kinaction_helloworld	Partition: 1	Leader: 0	Replicas: 0,2,1	Isr: 0,2,1
	Topic: kinaction_helloworld	Partition: 2	Leader: 2	Replicas: 2,1,0	Isr: 2,1,0
om@work:~$



Write something into a topic
    bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092


Read the topic
    bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092


