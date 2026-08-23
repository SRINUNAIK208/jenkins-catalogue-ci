# FROM node:20 
# WORKDIR /app 
# COPY package.json .
# RUN npm install 
# COPY server.js . 
# CMD ["node", "server.js"]


FROM node:26-alpine3.23 AS builder 
WORKDIR /app 
COPY package.json . 
RUN npm install 
COPY *.js . 

FROM node:26-alpine3.23 
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop
ENV MONGO="true" \
    MONGO_URL="mongodb://mongodb:27017/catalogue"
WORKDIR /app
COPY --from=builder /app  ./
USER roboshop
EXPOSE 8080
CMD ["node", "server.js"]
