# Aegir Environment

## Setup Steps

### Mac

Install kitematic toolbox and run this from the Docker Terminal

### Linux

Install docker with:
```bash
sudo apt-get install -y aufs-tools apparmor python-setuptools && curl http://get.docker.io | sudo sh
```

## Run Steps

```bash
docker run -d --name=aegir -p 80:80 -p 443:443 hrwebasst/aegir
```

### Add the following to your hosts file:

#### Mac

192.168.99.100 aegir1.aegir.dev

#### Linux

127.0.0.1 aegir1.aegir.dev

Or if you want the container ip (changes on each run and would need update on each run):

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' aegir
```

## Further Usage

We have created a container and named it "aegir"

You can stop the container or start it with the following commands even after reboot you can start this anytime

```bash
docker stop aegir
docker start aegir
```

To remove the container and all data

```bash
docker rm aegir
```