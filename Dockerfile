# 베이스 이미지: nginx의 경량 버전(alpine)을 사용
FROM nginx:alpine

# app 폴더(index.html이 있는 곳)를 nginx의 기본 서빙 경로로 복사
COPY app/ /usr/share/nginx/html/