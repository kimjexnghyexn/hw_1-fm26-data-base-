# FM26 선수 데이터 확인 앱

## 1. 프로젝트 개요

FM26(Football Manager 26)에서 영감을 받아, 선수 이름과 능력치 데이터(포텐셜)를 직접 정리한 파일(`players.txt`)을 만들고, 이를 Docker 컨테이너(nginx)로 실행되는 정적 웹 페이지(`app/index.html`)를 통해 브라우저로 확인할 수 있도록 만든 프로젝트.

이 과정에서 터미널(CLI) 기본 조작, 파일 권한 관리, Docker 이미지/컨테이너 운영, 포트 매핑, 바인드 마운트, 볼륨을 이용한 데이터 영속성, Git/GitHub 버전 관리를 직접 실습하고 검증했다.

## 2. 실행 환경

| OS | Windows 11 + WSL2 (Ubuntu 22.04) |
| 쉘/터미널 | bash |
| Docker 버전 | version 29.6.2, build dfc4efb|
| Git 버전 | version 2.55.0.3 |

## 3. 수행 항목 체크리스트

- [x] 터미널 기초 명령어
- [x] 파일/디렉토리 권한 변경 실습
- [x] Docker 설치 및 데몬 점검
- [x] Docker 기본 운영 명령
- [x] `hello-world` / `ubuntu` 컨테이너 실행 및 exec/attach 차이 관찰
- [x] Dockerfile 작성 및 커스텀 이미지
- [x] 포트 매핑 및 접속 확인
- [x] 바인드 마운트로 변경사항 실시간 반영 확인
- [x] Docker 볼륨 생성 및 데이터 영속성 검증
- [x] Git 설정
- [x] GitHub 저장소 연동 (VSCode 로그인 및 push)

## 4. 검증 방법

### 4-1. 터미널 기초 명령어

기본적 터미널 조작을 통해 프로젝트의 바탕이되는 파일을 만들 예정.

`pwd`로 현재 위치가 알맞은 폴더(fm26)에 있는지 확인하고, `touch`로 빈 선수 데이터 파일(players.txt)을 생성한 뒤 `ls -al`로
목록(생성 여부와 권한 및 숨겨진 파일)을 확인했다.

```bash
$ pwd
/home/user/fm26

$ touch players.txt
$ ls -al
total 8
drwxr-xr-x 2 user user 4096 Aug  4 21:01 .
drwxr-x--- 7 user user 4096 Aug  4 20:42 ..
-rw-r--r-- 1 user user    0 Aug  4 21:01 players.txt
```

→ `~/fm26` 경로에 크기 0인 빈 파일이 생성되었고, 소유자(user)에게 읽기/쓰기 권한(`rw-`)이 있음을 확인했다.

`>`(덮어쓰기)로 첫 데이터를 넣고, `>>`(이어쓰기)로 선수를 추가한 뒤 `cat`으로 파일 내용을 확인했다.

```bash
$ echo "guagua -9" > players.txt
$ echo "messi 200" >> players.txt
$ echo "kai rooney -8.5" >> players.txt
$ cat players.txt
guagua -9
messi 200
kai rooney -8.5
```

→ 3명의 선수 데이터가 순서대로 누적 저장됨. `>>` 사용 시 기존 내용이 유지됨을 확인했다.

원본을 복사한 뒤 백업 전용 폴더를 만들어 이동시키고, 결과를 확인했다.

```bash
$ cp players.txt players_backup.txt
$ mkdir backup
$ mv players_backup.txt backup/
$ ls backup/
players_backup.txt
```

→ 원본(`players.txt`)은 루트에 유지되고, 복사본은 `backup/` 폴더로 분리됨을 확인했다.

파일명을 잘못 입력해 생성된 파일을 `rm`으로 삭제하고, 올바른 파일에 데이터를 추가했다.

```bash
$ echo "jj gabreil -8.5" >> playerd.txt   # 오타
$ rm playerd.txt
$ echo "jj gabreil -8.5" >> players.txt
$ cat players.txt
guagua -9
messi 200
kai rooney -8.5
jj gabreil -8.5
```

→ 불필요한 파일이 제거되고, 최종적으로 4명의 선수 데이터가 정상 저장됨을 확인했다.

하위 폴더로 이동 후 상위 폴더로 복귀하며 `pwd`로 위치를 검증했다.

```bash
$ cd backup
$ cd ..
$ pwd
/home/user/fm26
```

→ 상대 경로(`..`)로 상위 디렉토리 이동이 정상 동작함을 확인했다.

### 4-2. 권한 부여

파일 1개(`players.txt`), 디렉토리 1개(`backup`)에 대해 권한을 변경하고 전/후를 비교했다.

```bash
$ ls -l players.txt
-rw-r--r-- 1 user user 52 Aug  4 21:10 players.txt

$ chmod 444 players.txt
$ ls -l players.txt
-r--r--r-- 1 user user 52 Aug  4 21:10 players.txt
```

→ `players.txt`를 644(소유자 읽기/쓰기, 그룹·기타 읽기)에서 444(모두 읽기 전용)로 변경했다(개발자 혼자 임의로 선수 구성 변경 방지).
그 후 변경 시 오류 메세지가 뜨는 것을 확인했다.

```bash
$ ls -ld backup
drwxr-xr-x 2 user user 4096 Aug  4 21:03 backup

$ chmod 700 backup
$ ls -ld backup
drwx------ 2 user user 4096 Aug  4 21:03 backup
```

→ `backup` 디렉토리를 755(소유자 전체 권한, 그룹·기타 읽기+진입)에서 700(소유자만 접근 가능)으로 변경했다.(백업 파일을 다른 사람이 볼 이유가 없음)

기본적인 터미널 조작을 통해 폴더 및 파일을 만들었다. Docker를 설치 후 웹사이트를 다른이에게 서빙하는 작업을 하겠다.

### 4-4. Docker 설치 및 점검

```bash
$ docker --version
Docker version 29.6.2, build dfc4efb

$ docker info
Client:
 Version:    29.6.2
 ...
Server:
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

→ 클라이언트는 정상이나 서버 연결에서 권한 오류 발생(트러블슈팅 #1) 해결 후 재확인했다:

```bash
$ groups $USER
user : user adm cdrom sudo dip plugdev users docker

$ docker info
Client: ...
Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 29.6.2
 Storage Driver: overlayfs
 ...
 OSType: linux
 Architecture: x86_64
 CPUs: 16
 Total Memory: 15.4GiB
```

→ Server 섹션이 에러 없이 정상 출력됨. Docker 데몬 정상 동작 확인 완료.

### 4-5. Docker 기본 운영 명령

`hello-world` 이미지를 실행하여 도커 기본 library에서 이미지 pull → 컨테이너 생성 → 실행 흐름을 확인했다.

```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pull complete
d5e71e642bf5: Download complete
Status: Downloaded newer image for hello-world:latest
Hello from Docker!
This message shows that your installation appears to be working correctly.
...

$ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   7f4da0fc94bc       25.9kB         9.49kB    U

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
b621f92b2e5c   hello-world   "/hello"   38 seconds ago   Exited (0) 37 seconds ago             stoic_bhabha
```

→ 로컬에 없던 이미지가 자동으로 pull 되었고, 실행 후 컨테이너는 곧바로 `Exited (0)` 상태로 종료됨을 확인.

`ubuntu` 컨테이너에 직접 진입해 내부 명령을 실행했다.

```bash
$ docker run -it ubuntu bash
Unable to find image 'ubuntu:latest' locally
...
root@275aa207ab9c:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@275aa207ab9c:/# echo "hello from container"
hello from container
root@275aa207ab9c:/# exit
exit
```

→ `bash`가 컨테이너의 메인 프로세스였기 때문에 `exit` 시 컨테이너 자체도 함께 종료됨.

# (증거 사후 추가) 컨테이너가 종료되었다는 증거를 첨부함
```bash
$ b621f92b2e5c   hello-world    "/hello"                 23 hours ago     Exited (0) 23 hours ago
```

**컨테이너 종료(exit) vs 유지(exec) 차이 관찰**: 백그라운드로 컨테이너를 띄운 뒤, `exec`으로 들어갔다 나와도 컨테이너가 계속 살아있는지 확인했다.

```bash
$ docker run -d --name test-ubuntu ubuntu sleep 300
23d057946449516720f5ec583c7a1e3dc3facb4d7bcf24805e7b5ef7a528e58d

$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
23d057946449   ubuntu    "sleep 300"   5 seconds ago   Up 5 seconds             test-ubuntu

$ docker exec -it test-ubuntu bash
root@23d057946449:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@23d057946449:/# echo "people in here!!"
people in here!!
root@23d057946449:/# exit
exit

$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
23d057946449   ubuntu    "sleep 300"   51 seconds ago   Up 50 seconds             test-ubuntu

$ docker logs test-ubuntu
# 아무것도 나오지 않았다?. (트러블슈팅 #2 참조)

$ docker stop test-ubuntu
$ docker rm test-ubuntu
```

→ 메인 프로세스가 `sleep 300`이었기 때문에, `exec`으로 들어갔다 `exit`해도 컨테이너는 `Up` 상태로 계속 유지됨. `docker run -it ... exit`(종료)과 명확히 대조됨을 확인했다.

### 4-6. Dockerfile 기반 커스텀 이미지

- **선택 베이스**: `nginx:alpine` (방식 A: 웹서버 베이스 이미지 활용)
- **커스텀 포인트**: `app/index.html`(선수 이름/능력치 표)을 nginx 기본 서빙 경로로 교체했다.

```dockerfile
FROM nginx:alpine
COPY app/ /usr/share/nginx/html/
```

```bash
$ docker build -t fm26-web:1.0 .
[+] Building 7.4s (8/8) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load metadata for docker.io/library/nginx:alpine
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:...
 => [internal] load build context
 => [2/2] COPY app/ /usr/share/nginx/html/
 => exporting to image
 => => naming to docker.io/library/fm26-web:1.0
```

→ nginx:alpine 베이스에 `app/` 정적 콘텐츠를 교체하여 커스텀 이미지 빌드 성공.

### 4-7. 포트 매핑 및 접속 확인

```bash
$ docker run -d --name fm26-web -p 8080:80 fm26-web:1.0
114e9e26020e9cad165d0ededc8bdddd030f434d8ef7a9e3844ebc76854115af

$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                 NAMES
114e9e26020e   fm26-web:1.0   "/docker-entrypoint.…"   16 seconds ago   Up 15 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   fm26-web

$ curl http://localhost:8080
<!DOCTYPE html>
<html lang="ko">
...
<h1>FM26 Players</h1>
<table border="1" cellpadding="8"> ... </table>
```

→ 호스트 8080번 포트가 컨테이너 80번(nginx)에 정상 매핑되어, `curl` 응답으로 `index.html` 내용이 그대로 반환됨을 확인하였고 그 증거로 브라우저 접속 사진을 첨부함.

**브라우저 접속 증거**: `http://localhost:8080` 접속 확인 완료.
![매핑성공](<스크린샷 2026-08-05 121840.png>)

### 4-8. 바인드 마운트 검증

```bash
$ docker stop fm26-web
$ docker rm fm26-web
$ docker run -d --name fm26-web -p 8080:80 -v ~/fm26/app:/usr/share/nginx/html fm26-web:1.0
```

호스트의 `app/` 폴더를 컨테이너의 nginx 서빙 경로에 실시간 연결(바인드 마운트)한 뒤, 호스트에서 `app/index.html`을 수정하고(선수 한명을 더 추가했으며, Rating을 Pot(포텐셜)로 바꾸었다.) 컨테이너 재빌드 없이 반영되는지 확인했다.
![수정 전](<스크린샷 2026-08-05 121840-1.png>)
![수정 후](<스크린샷 2026-08-05 141627.png>)

### 4-9. 볼륨 영속성 검증

**Step A: 볼륨 없이 → 컨테이너 삭제 시 데이터 사라짐 확인**

```bash
$ docker run -d --name fm26-web -p 8080:80 -v ~/fm26/app:/usr/share/nginx/html fm26-web:1.0
0eb45d5c8be0c2754e153af91c10413f63401da91ccfa8eb131de93ccfdbb9ff

$ docker exec fm26-web sh -c 'echo "1st visit logged" > /visit-log.txt'
$ docker exec fm26-web cat /visit-log.txt
1st visit logged

$ docker stop fm26-web
$ docker rm fm26-web
$ docker run -d --name fm26-web -p 8080:80 -v ~/fm26/app:/usr/share/nginx/html fm26-web:1.0
86b284c5a4b3a9b965d75209d42feb3e49e2449f1a3f2ec264e0ce9adf70e4cd

$ docker exec fm26-web cat /visit-log.txt
cat: can't open '/visit-log.txt': No such file or directory 
```

→ 볼륨 없이 컨테이너 내부에 저장한 데이터는 컨테이너 삭제 시 함께 사라짐을 확인.

**Step B: 볼륨 연결 → 컨테이너 삭제해도 데이터 유지 확인**

```bash
$ docker volume create fm26-data
fm26-data

$ docker stop fm26-web
$ docker rm fm26-web
$ docker run -d --name fm26-web -p 8080:80 -v ~/fm26/app:/usr/share/nginx/html -v fm26-data:/persist fm26-web:1.0
d33feecbb0a681fe18f530e4e4e4c17b55c4977d57fe65daa85e5ad1f8c2fb33

$ docker exec fm26-web sh -c 'echo "1st visit logged" > /persist/visit-log.txt'
$ docker exec fm26-web cat /persist/visit-log.txt
1st visit logged

$ docker stop fm26-web
$ docker rm fm26-web
$ docker run -d --name fm26-web -p 8080:80 -v ~/fm26/app:/usr/share/nginx/html -v fm26-data:/persist fm26-web:1.0
4a602d909cb9332460e34a8a5efda8b67e77051bc14838282c38078d3b6d33bd

$ docker exec fm26-web cat /persist/visit-log.txt
1st visit logged
```

→ `fm26-data` 볼륨에 저장한 데이터는 컨테이너를 완전히 삭제하고 새로 생성해도 그대로 유지됨을 확인. Step A(사라짐)와 Step B(유지됨)의 대조로 볼륨의 데이터 영속성을 검증함.

### 4-10. Git 설정

```bash
$ git config --list
user.name=kimjexnghyexn
user.email=kimjexnghyexn@gmail.com
init.defaultbranch=main
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
```

→ 사용자 이름/이메일, 기본 브랜치(main)가 정상 설정됨을 확인.

**GitHub 연동**


## 6. 트러블슈팅

### 트러블슈팅 #1: `docker info` 실행 시 permission denied

- **문제**: `docker info` 실행 시 Client 정보는 정상 출력되지만, Server 섹션에서 `permission denied while trying to connect to the docker API at unix:///var/run/docker.sock` 에러 발생
- **원인 가설**: 현재 WSL 사용자 계정이 `docker` 그룹에 속해있지 않아 Docker 소켓(`/var/run/docker.sock`)에 접근 권한이 없음
- **확인**: `groups $USER` 실행 결과 `docker` 그룹이 목록에 없는 것을 확인
- **해결/대안**: `sudo usermod -aG docker $USER`로 계정을 `docker` 그룹에 추가. 그룹 변경사항을 즉시 반영하기 위해 재로그인 필요

### 트러블슈팅 #2: `docker logs test-ubuntu` 실행 결과가 비어있음

- **문제**: `test-ubuntu` 컨테이너에 `docker exec`로 들어가 `echo` 명령까지 실행했는데도, `docker logs test-ubuntu`를 실행하면 아무 출력도 나오지 않음
- **원인 가설**: `docker logs`가 컨테이너 안에서 일어난 모든 동작을 기록하는 게 아니라, 특정 프로세스의 출력만 캡처하는 것으로 추정. `test-ubuntu`의 메인 프로세스는 `sleep 300`인데, 이 명령은 애초에 화면에 아무것도 출력하지 않으므로 로그가 비어있는 게 정상일 가능성이 있음
- **확인**: 실제 서비스가 동작 중인 `fm26-web`(nginx) 컨테이너에 동일하게 `docker logs fm26-web`을 실행. nginx의 시작 로그와, `curl`/브라우저로 접속했던 HTTP 요청 기록(`GET / HTTP/1.1" 200 ...`)이 정상적으로 출력됨을 확인
- **해결/대안**: `docker logs`는 컨테이너의 **메인 프로세스(PID 1)가 표준출력(stdout)으로 내보내는 내용만** 보여준다는 것을 확인함. `test-ubuntu`는 메인 프로세스가 `sleep`이라 원래 출력이 없어 로그가 비어있는 게 정상 동작이었고, `docker exec`로 들어가서 실행한 `echo`는 그 exec 세션 화면에만 표시될 뿐 컨테이너의 로그에는 기록되지 않는다는 것을 이해함. 이후 `docker logs` 검증 항목은 실제로 접속 기록이 남는 `fm26-web` 컨테이너 결과로 대체하여 기록함

```bash
$ docker logs fm26-web
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/08/05 04:07:15 [notice] 1#1: using the "epoll" event method
2026/08/05 04:07:15 [notice] 1#1: nginx/1.31.3
2026/08/05 04:07:15 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0) 
2026/08/05 04:07:15 [notice] 1#1: OS: Linux 6.18.33.2-microsoft-standard-WSL2
2026/08/05 04:07:15 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/08/05 04:07:15 [notice] 1#1: start worker processes
2026/08/05 04:07:15 [notice] 1#1: start worker process 30
...
2026/08/05 04:07:15 [notice] 1#1: start worker process 45
172.17.0.1 - - [05/Aug/2026:05:16:14 +0000] "GET / HTTP/1.1" 200 565 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0" "-"   
172.17.0.1 - - [06/Aug/2026:02:22:43 +0000] "GET / HTTP/1.1" 200 565 "-" "curl/8.18.0" "-"
172.17.0.1 - - [06/Aug/2026:02:22:51 +0000] "GET / HTTP/1.1" 200 565 "-" "curl/8.18.0" "-"
```