# nomad-in-a-box

# how to use

## local development on your laptop
```
vagrant up
```

Then you can reach the services at

consul http://localhost:8500	-> consul1

nomad http://localhost:4646	-> nomad1

vault http://localhost:8200 	-> vault1

To reach each of the individual nodes, you can use:

- consul
	- consul1 = http://consul1.127.0.0.1.xip.io:8080
	- consul2 = http://consul2.127.0.0.1.xip.io:8080
	- consul3 = http://consul3.127.0.0.1.xip.io:8080

- nomad
	- nomad1 = http://nomad1.127.0.0.1.xip.io:8080
	- nomad2 = http://nomad2.127.0.0.1.xip.io:8080
	- nomad3 = http://nomad3.127.0.0.1.xip.io:8080

- vault
	- vault1 = http://vault1.127.0.0.1.xip.io:8080

### terraform and nomad

in `tf_local` there is a terraform project you can use to schedule jobs in the nomad cluster.

This will add 3 jobs in nomad, that using consul-template will create the configuration needed to 
make the site available at  http://http-echo.127.0.0.1.xip.io:8080


## On packet.net

```
cd tf_packet
terraform apply
```

Then in the output will be the aliases you can use to reach each service.

replace `n.n.n.n` with the ip of the instance, or just use the url printed by terraform.

- consul
	- consul1 = http://consul1.n.n.n.n.xip.io
	- consul2 = http://consul2.n.n.n.n.xip.io
	- consul3 = http://consul3.n.n.n.n.xip.io

- nomad
	- nomad1 = http://nomad1.n.n.n.n.xip.io
	- nomad2 = http://nomad2.n.n.n.n.xip.io
	- nomad3 = http://nomad3.n.n.n.n.xip.io

- vault
	- vault1 = http://vault1.n.n.n.n.xip.io

You can reach the services also on the default port like in the development box

consul http://n.n.n.n:8500	-> consul1

nomad http://n.n.n.n:4646	-> nomad1

vault http://n.n.n.n:8200 	-> vault1

## description

This projects uses LXD to create containers.

```
# lxc list
+----------+---------+--------------------------------+------+------------+-----------+
|   NAME   |  STATE  |              IPV4              | IPV6 |    TYPE    | SNAPSHOTS |
+----------+---------+--------------------------------+------+------------+-----------+
| base     | STOPPED |                                |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| client1  | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.158 (eth0)           |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| client10 | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.55 (eth0)            |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| client11 | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.14 (eth0)            |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| client12 | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.95 (eth0)            |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| client2  | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.152 (eth0)           |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| client3  | RUNNING | 172.17.0.1 (docker0)           |      | PERSISTENT | 0         |
|          |         | 10.170.13.239 (eth0)           |      |            |           |
+----------+---------+--------------------------------+------+------------+-----------+
| consul1  | RUNNING | 10.170.13.11 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| consul2  | RUNNING | 10.170.13.12 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| consul3  | RUNNING | 10.170.13.13 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| nomad1   | RUNNING | 10.170.13.31 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| nomad2   | RUNNING | 10.170.13.32 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| nomad3   | RUNNING | 10.170.13.33 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
| vault1   | RUNNING | 10.170.13.21 (eth0)            |      | PERSISTENT | 0         |
+----------+---------+--------------------------------+------+------------+-----------+
# 
```
