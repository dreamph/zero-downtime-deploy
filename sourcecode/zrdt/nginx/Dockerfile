FROM nginx:1.25.3-alpine

RUN apk add --no-cache bash curl tzdata openssl
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]