###
# WUMPUS v 0.0.3 build system
###
DATA=data
WORKDIR=/root
VERSION=latest
WUMPUS=up1ps/wumpus:$(VERSION)
PORTS=8081:8081
#DOCKERMOUNT= -v $(PWD)/$(DATA):$(WORKDIR)/$(DATA)
DOCKERMOUNT=
DOCKEROPTS=  -t -d -p $(PORTS)
DOCKERCOMMAND= run $(DOCKEROPTS) $(DOCKERMOUNT) $(WUMPUS)
ATTACHOPTS=  -i -t -p $(PORTS)
ATTACHCOMMAND= run $(ATTACHOPTS) $(DOCKERMOUNT) $(WUMPUS)
PS := $(shell docker ps | grep wumpus | cut -d " " -f1)

.PHONY: all run ba nba exec cid stop clean

# Just build the docker image
all: 
	docker build -t $(WUMPUS) .

# Just run the docker image
run:
	docker $(DOCKERCOMMAND)

# Build and then run the image and attach to the container
ba: clean all
	docker $(ATTACHCOMMAND)

# Justun the image and attach to the container
nba:
	docker $(ATTACHCOMMAND)

# Get an interactive terminal on the container
exec:
	docker exec -it $(PS) /bin/bash

# Hook into the tool's Logfile to observe its behavior
tail:
	docker exec -it $(PS) tail -f /root/httpd.log

# Get the tool's process id
cid:
	@echo $(PS)

# stop the container when detached
stop:
	docker stop -t 0 $(PS)

# clean the docker environment
clean:
	docker container prune -f
	docker image prune -f
	docker volume prune -f
