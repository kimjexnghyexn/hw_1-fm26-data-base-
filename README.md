# FM26 선수 데이터 웹앱

## 1. 프로젝트 개요
(fm26게임에서 영감을 받아, 직접 선수의 능력치를 설정 및 변경하며 이를 다른 사람들이 확인할 수 있도록 웹사이트를 만듦)

## 2. 실행 환경
- OS: Windows 11 + WSL2 (Ubuntu 22.04)
- 쉘: bash
- Docker: (docker --version 4.85.0)
- Git: (git --version 2.55.0.3)

## 3. 수행 항목 체크리스트
- [x] 터미널 기초 명령어
- [ ] 권한(chmod)
- [ ] Docker / Dockerfile
- [ ] 포트 / 마운트 / 볼륨
- [ ] Git / GitHub

## 4. 수행 결과 및 검증 방법

### 4-1.터미널 기초 명령어

`pwd`로 현재 위치를 확인하고, `touch`로 빈 선수 데이터 파일을 생성한 뒤 `ls -al`로 
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

→ `~/fm26` 경로에 크기 0인 빈 파일이 생성되었고, 소유자(user)에게 읽기/쓰기 권한(`rw-`)이 있음을 확인.

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

→ 3명의 선수 데이터가 순서대로 누적 저장됨. `>>` 사용 시 기존 내용이 유지됨을 확인.

원본을 복사한 뒤 백업 전용 폴더를 만들어 이동시키고, 결과를 확인했다.

```bash
$ cp players.txt players_backup.txt
$ mkdir backup
$ mv players_backup.txt backup/
$ ls backup/
players_backup.txt
```

→ 원본(`players.txt`)은 루트에 유지되고, 복사본은 `backup/` 폴더로 분리됨을 확인.

파일명을 잘못 입력해 생성된 파일을 `rm`으로 삭제하고, 올바른 파일에 데이터를 추가했다.

```bash
$ echo "jj gabreil -8.5" >> playerd.txt   # 오타: playerd
$ rm playerd.txt
$ echo "jj gabreil -8.5" >> players.txt
$ cat players.txt
guagua -9
messi 200
kai rooney -8.5
jj gabreil -8.5
```

→ 불필요한 파일이 제거되고, 최종적으로 4명의 선수 데이터가 정상 저장됨을 확인.

### 4-5. 디렉토리 이동 (`cd`)

하위 폴더로 이동 후 상위 폴더로 복귀하며 `pwd`로 위치를 검증했다.

```bash
$ cd backup
$ cd ..
$ pwd
/home/user/fm26
```

→ 상대 경로(`..`)로 상위 디렉토리 이동이 정상 동작함을 확인.

## 5. 트러블슈팅
### 사례 1: g++ 부재 문제
- 문제 → 원인 가설 → 확인 → 해결 (Docker 멀티스테이지)
### 사례 2: Windows 권한 문제
- 문제 → 원인 가설 → 확인 → 해결 (WSL2 도입)