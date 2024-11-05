# Beaver IoT Docker

## Requirements

-  Docker: 20.10 or newer

## Build

### 准备工作

进入`build-docker`目录, 创建`.env`配置文件:

```shell
touch build-docker/.env
```

编辑`.env`配置文件, 内容如下:

```dotenv
# docker仓库地址(如果有)
DOCKER_REGISTRY=
# 镜像tag
PRODUCTION_TAG=latest
# git地址和分支
WEB_GIT_REPO_URL=https://github.com/beaver-iot/beaver-iot-web.git
WEB_GIT_BRANCH=origin/master
SERVER_GIT_REPO_URL=https://github.com/beaver-iot/beaver-iot.git
SERVER_GIT_BRANCH=origin/master
# maven仓库账号密码(如果有)
MVN_USERNAME=
MVN_PASSWORD=
```

> 后续构建步骤无论使用build.sh还是docker compose, 都会使用该文件中的配置



### 通过Bash脚本构建

直接执行build-docker/build.sh开始构建:

```shell
./build-docker/build.sh --load
```

如果您仅需要构建其中一个或几个镜像, 可以通过`--build-target`参数来指定

```shell
./build-docker/build.sh --load --build-target=server,monolith
```

此外, 您可以直接传递额外配置项给docker build

```shell
./build-docker/build.sh --process=plain --load
```

> 注意, 环境变量配置的优先级会高于命令行参数

 其他配置项, 可以通过--help选项查看

```shell
./build-docker/build.sh --help
```



### 通过Docker Compose构建 (Beta)

如果您没有Bash环境, 也可以通过新版本的Docker Compose直接构建镜像:

```shell
cd build-docker && docker compose build --no-cache
```



## Run

### 通过docker run启动 (Monolith)

执行命令启动服务
```shell
docker run --rm -d -p 80:80 -v $(pwd)/target/beaver-iot:/root/beaver-iot beaver-iot/monolith:latest
```



### 通过docker compose启动

请参考examples目录下的示例编写docker-compose文件, 并通过docker-compose执行, 例如:
```shell
docker compose -f quick-start.yaml up -d
```

> 注意: 您不应该将examples目录下的示例直接用于生产环境, 因为其中的部分端口和配置并不安全



## Configuration

### Web

#### Environment Variables

todo



#### Ports

todo



### Server



### Monolith



### Plugins

挂载容器的`/root/beaver-iot/plugins`目录, 将插件包放到该目录下, 并重启服务



## Release

如果需要发布docker镜像, 请先登录镜像仓库

```shell
docker login <target-docker-registry>
```

由于beaver-iot目前支持arm和x86架构, 因此发布时通常会需要同时构建这两个平台的产物, 这就需要用到docker的跨平台编译功能, 如果您此前没有进行过相关操作, 请按照如下步骤开启:

 1.  编辑/etc/docker/daemon.json, 添加experimental选项:

     ```json
     {
         "experimental": true
         ...
     }
     ```

 2.  重启docker daemon

 3.  创建builder
     ```shell
     docker buildx create --use --name build --node build --driver-opt network=host --bootstrap
     ```

之后就和此前的构建步骤一样, 执行build脚本, 但是这次除了之前的配置之外, 还需要加上push和目标平台选项:

```shell
TARGET_PLATFORM=linux/arm64,linux/amd64 DOCKER_BUILD_OPTION_PUSH=true PRODUCTION_TAG=<your-tag> ./build-docker/build.sh
```

> 和之前一样, 环境变量也可以写在.env中

接下来, 只需要耐心等待完成即可
