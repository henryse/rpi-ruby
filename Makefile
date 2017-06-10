ifdef VERSION
	project_version:=$(VERSION)
else
	project_version:=$(shell git rev-parse --short=8 HEAD)
endif

ifdef PROJECT_NAME
	project_name:=$(PROJECT_NAME)
else
	project_name:=$(shell basename $(CURDIR))
endif

ifdef SRC_DIR
	source_directory:=$(SRC_DIR)
else
	source_directory:=$(CURDIR)/image
endif

repository:=henryse/$(project_name)
latest_image:=$(repository):latest
version_image:=$(repository):$(project_version)
docker_tag_cmd:=docker tag

version:
	@echo [INFO] [version]
	@echo [INFO]    Build Makefile Version 1.01
	@echo

settings: version
	@echo [INFO] [settings]
	@echo [INFO]    project_version=$(project_version)
	@echo [INFO]    project_name=$(project_name)
	@echo [INFO]    docker_tag_cmd=$(docker_tag_cmd)
	@echo [INFO]    repository=$(repository)
	@echo [INFO]    latest_image=$(latest_image)
	@echo [INFO]    version_image=$(version_image)
	@echo [INFO]    source_directory=$(source_directory)

help: settings
	@printf "\e[1;34m[INFO] [information]\e[00m\n\n"
	@echo [INFO] This make process supports the following targets:
	@echo [INFO]    clean       - clean up and targets in project
	@echo [INFO]    build       - build both the project and Docker image
	@echo [INFO]    push        - push image to repository
	@echo
	@echo [INFO] The script supports the following parameters:
	@echo [INFO]    VERSION      - version to tag docker image wth, default value is the git hash
	@echo [INFO]    PROJECT_NAME - project name, default is git project name
	@echo [INFO]    SRC_DIR      - source code, default is "image"
	@echo
	@echo [INFO] This tool expects the project to be located in a directory called image.
	@echo [INFO] If there is a Makefile in the image directory, then this tool will execute it
	@echo [INFO] with either clean and build targets.
	@echo
	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     docker run -t -i  $(version_image)

build_docker:
	docker build --rm --build-arg PROJECT_VERSION=$(project_version) --build-arg PROJECT_NAME=$(project_name) --tag $(version_image) $(source_directory)
	$(docker_tag_cmd) $(version_image) $(latest_image)

	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     docker run -t -i  $(version_image)
	@echo [INFO]

build: settings build_docker

clean: settings
	docker images | grep '<none>' | awk '{system("docker rmi -f " $$3)}'
	docker images | grep '$(repository)' | awk '{system("docker rmi -f " $$3)}'

push: settings build_docker
	$(docker_tag_cmd)  $(version_image) $(latest_image)
	docker push $(version_image)
	docker push $(latest_image)

