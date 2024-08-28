FROM node:20-alpine AS builder

RUN apk update && \
    apk add git ffmpeg wget curl bash

LABEL version="2.1.0" description="Api to control whatsapp features through http requests." 
LABEL maintainer="Davidson Gomes" git="https://github.com/DavidsonGomes"
LABEL contact="contato@atendai.com"

WORKDIR /evolution

COPY ./package.json ./
COPY ./tsconfig.json ./

RUN npm install

COPY ./src ./src
COPY ./public ./public
COPY ./prisma ./prisma
COPY ./manager ./manager
COPY ./.env.example ./.env
COPY ./runWithProvider.js ./
COPY ./tsup.config.ts ./

COPY ./Docker ./Docker

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*

RUN ./Docker/scripts/generate_database.sh

RUN npm run build

FROM node:20-alpine AS final

RUN apk update && \
    apk add tzdata ffmpeg bash

ENV TZ=America/Sao_Paulo

WORKDIR /evolution

COPY --from=builder /evolution/package.json ./package.json
COPY --from=builder /evolution/package-lock.json ./package-lock.json

COPY --from=builder /evolution/node_modules ./node_modules
COPY --from=builder /evolution/dist ./dist
COPY --from=builder /evolution/prisma ./prisma
COPY --from=builder /evolution/manager ./manager
COPY --from=builder /evolution/public ./public
COPY --from=builder /evolution/.env ./.env
COPY --from=builder /evolution/Docker ./Docker
COPY --from=builder /evolution/runWithProvider.js ./runWithProvider.js
COPY --from=builder /evolution/tsup.config.ts ./tsup.config.ts

ENV DOCKER_ENV=true

ENV SERVER_TYPE=https
ENV SERVER_PORT=8080
# Server URL - Set your application url
ENV SERVER_URL=http://localhost:8080

ENV SENTRY_DSN=

# Cors - * for all or set separate by commas -  ex.: 'yourdomain1.com, yourdomain2.com'
ENV CORS_ORIGIN=*
ENV CORS_METHODS=GET,POST,PUT,DELETE
ENV CORS_CREDENTIALS=true

# Determine the logs to be displayed
ENV LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS,WEBSOCKET
ENV LOG_COLOR=true
# Log Baileys - "fatal" | "error" | "warn" | "info" | "debug" | "trace"
ENV LOG_BAILEYS=error

# Determine how long the instance should be deleted from memory in case of no connection.
# Default time: 5 minutes
# If you don't even want an expiration, enter the value false
ENV DEL_INSTANCE=false

# Provider: postgresql | mysql
ENV DATABASE_PROVIDER=postgresql
ENV DATABASE_CONNECTION_URI='postgresql://postgres.gaxmzqbmfmkwohdvmzlj:mQjHCkEKgzNsU15u@aws-0-us-west-1.pooler.supabase.com:5432/postgres?schema=public'
# Client name for the database connection
# It is used to separate an API installation from another that uses the same database.
ENV DATABASE_CONNECTION_CLIENT_NAME=evolution_exchange

# Choose the data you want to save in the application's database
ENV DATABASE_SAVE_DATA_INSTANCE=true
ENV DATABASE_SAVE_DATA_NEW_MESSAGE=true
ENV DATABASE_SAVE_MESSAGE_UPDATE=true
ENV DATABASE_SAVE_DATA_CONTACTS=true
ENV DATABASE_SAVE_DATA_CHATS=true
ENV DATABASE_SAVE_DATA_LABELS=true
ENV DATABASE_SAVE_DATA_HISTORIC=true

# RabbitMQ - Environment ENV variables
ENV RABBITMQ_ENABLED=false
ENV RABBITMQ_URI=amqp://localhost
ENV RABBITMQ_EXCHANGE_NAME=evolution
# Global events - By enabling this variable, events from all instances are sent in the same event queue.
ENV RABBITMQ_GLOBAL_ENABLED=false
# Choose the events you want to send to ENV RabbitMQ
ENV RABBITMQ_EVENTS_APPLICATION_STARTUP=false
ENV RABBITMQ_EVENTS_INSTANCE_CREATE=false
ENV RABBITMQ_EVENTS_INSTANCE_DELETE=false
ENV RABBITMQ_EVENTS_QRCODE_UPDATED=false
ENV RABBITMQ_EVENTS_MESSAGES_SET=false
ENV RABBITMQ_EVENTS_MESSAGES_UPSERT=false
ENV RABBITMQ_EVENTS_MESSAGES_EDITED=false
ENV RABBITMQ_EVENTS_MESSAGES_UPDATE=false
ENV RABBITMQ_EVENTS_MESSAGES_DELETE=false
ENV RABBITMQ_EVENTS_SEND_MESSAGE=false
ENV RABBITMQ_EVENTS_CONTACTS_SET=false
ENV RABBITMQ_EVENTS_CONTACTS_UPSERT=false
ENV RABBITMQ_EVENTS_CONTACTS_UPDATE=false
ENV RABBITMQ_EVENTS_PRESENCE_UPDATE=false
ENV RABBITMQ_EVENTS_CHATS_SET=false
ENV RABBITMQ_EVENTS_CHATS_UPSERT=false
ENV RABBITMQ_EVENTS_CHATS_UPDATE=false
ENV RABBITMQ_EVENTS_CHATS_DELETE=false
ENV RABBITMQ_EVENTS_GROUPS_UPSERT=false
ENV RABBITMQ_EVENTS_GROUP_UPDATE=false
ENV RABBITMQ_EVENTS_GROUP_PARTICIPANTS_UPDATE=false
ENV RABBITMQ_EVENTS_CONNECTION_UPDATE=false
ENV RABBITMQ_EVENTS_REMOVE_INSTANCE=false
ENV RABBITMQ_EVENTS_LOGOUT_INSTANCE=false
ENV RABBITMQ_EVENTS_CALL=false
ENV RABBITMQ_EVENTS_TYPEBOT_START=false
ENV RABBITMQ_EVENTS_TYPEBOT_CHANGE_STATUS=false

# SQS - Environment variables
ENV SQS_ENABLED=false
ENV SQS_ACCESS_KEY_ID=
ENV SQS_SECRET_ACCESS_KEY=
ENV SQS_ACCOUNT_ID=
ENV SQS_REGION=

# Websocket - Environment variables
ENV WEBSOCKET_ENABLED=false
ENV WEBSOCKET_GLOBAL_EVENTS=false

# WhatsApp Business API - Environment variables
# Token used to validate the webhook on the Facebook APP
ENV WA_BUSINESS_TOKEN_WEBHOOK=evolution
ENV WA_BUSINESS_URL=https://graph.facebook.com
ENV WA_BUSINESS_VERSION=v20.0
ENV WA_BUSINESS_LANGUAGE=en_US

# Global Webhook Settings
# Each instance's Webhook URL and events will be requested at the time it is created
ENV WEBHOOK_GLOBAL_ENABLED=false
# Define a global webhook that will listen for enabled events from all instances
ENV WEBHOOK_GLOBAL_URL='webhook_global_url'
# With this option activated, you work with a url per webhook event, respecting the global url and the name of each event
ENV WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false
# Set the events you want to hear
ENV WEBHOOK_EVENTS_APPLICATION_STARTUP=false
ENV WEBHOOK_EVENTS_QRCODE_UPDATED=true
ENV WEBHOOK_EVENTS_MESSAGES_SET=true
ENV WEBHOOK_EVENTS_MESSAGES_UPSERT=true
ENV WEBHOOK_EVENTS_MESSAGES_EDITED=true
ENV WEBHOOK_EVENTS_MESSAGES_UPDATE=true
ENV WEBHOOK_EVENTS_MESSAGES_DELETE=true
ENV WEBHOOK_EVENTS_SEND_MESSAGE=true
ENV WEBHOOK_EVENTS_CONTACTS_SET=true
ENV WEBHOOK_EVENTS_CONTACTS_UPSERT=true
ENV WEBHOOK_EVENTS_CONTACTS_UPDATE=true
ENV WEBHOOK_EVENTS_PRESENCE_UPDATE=true
ENV WEBHOOK_EVENTS_CHATS_SET=true
ENV WEBHOOK_EVENTS_CHATS_UPSERT=true
ENV WEBHOOK_EVENTS_CHATS_UPDATE=true
ENV WEBHOOK_EVENTS_CHATS_DELETE=true
ENV WEBHOOK_EVENTS_GROUPS_UPSERT=true
ENV WEBHOOK_EVENTS_GROUPS_UPDATE=true
ENV WEBHOOK_EVENTS_GROUP_PARTICIPANTS_UPDATE=true
ENV WEBHOOK_EVENTS_CONNECTION_UPDATE=true
ENV WEBHOOK_EVENTS_REMOVE_INSTANCE=false
ENV WEBHOOK_EVENTS_LOGOUT_INSTANCE=false
ENV WEBHOOK_EVENTS_LABELS_EDIT=true
ENV WEBHOOK_EVENTS_LABELS_ASSOCIATION=true
ENV WEBHOOK_EVENTS_CALL=true
# This events is used with Typebot
ENV WEBHOOK_EVENTS_TYPEBOT_START=false
ENV WEBHOOK_EVENTS_TYPEBOT_CHANGE_STATUS=false
# This event is used to send errors
ENV WEBHOOK_EVENTS_ERRORS=false
ENV WEBHOOK_EVENTS_ERRORS_WEBHOOK=

# Name that will be displayed on smartphone connection
ENV CONFIG_SESSION_PHONE_CLIENT="Evolution API"
# Browser Name = Chrome | Firefox | Edge | Opera | Safari
ENV CONFIG_SESSION_PHONE_NAME=Chrome

# Whatsapp Web version for baileys channel
# https://web.whatsapp.com/check-update?version=0&platform=web
ENV CONFIG_SESSION_PHONE_VERSION=2.3000.1015901307

# Set qrcode display limit
ENV QRCODE_LIMIT=30
# Color of the QRCode on base64
ENV QRCODE_COLOR='#175197'

# Typebot - Environment variables
ENV TYPEBOT_ENABLED=false
# old | latest

# Dify - Environment variables
ENV DIFY_ENABLED=false

# Cache - Environment variables
# Redis Cache enabled
ENV CACHE_REDIS_ENABLED=true
ENV CACHE_REDIS_URI=redis://red-cr4u77tumphs73dthssg:6379
# Prefix serves to differentiate data from one installation to another that are using the same redis
ENV CACHE_REDIS_PREFIX_KEY=evolution
# Enabling this variable will save the connection information in Redis and not in the database.
ENV CACHE_REDIS_SAVE_INSTANCES=false
# Local Cache enabled
ENV CACHE_LOCAL_ENABLED=false

# Amazon S3 - Environment variables
ENV S3_ENABLED=false
ENV S3_ACCESS_KEY=
ENV S3_SECRET_KEY=
ENV S3_BUCKET=evolution
ENV S3_PORT=443
ENV S3_ENDPOINT=s3.domain.com
ENV S3_REGION=eu-west-3
ENV S3_USE_SSL=true

# AMAZON S3 - Environment variables
# S3_ENABLED=true
# S3_BUCKET=bucket_name
# S3_ACCESS_KEY=access_key_id
# S3_SECRET_KEY=secret_access_key
# S3_ENDPOINT=s3.amazonaws.com # region: s3.eu-west-3.amazonaws.com
# S3_REGION=eu-west-3

# MINIO Use SSL - Environment variables
# S3_ENABLED=true
# S3_ACCESS_KEY=access_key_id
# S3_SECRET_KEY=secret_access_key
# S3_BUCKET=bucket_name
# S3_PORT=443
# S3_ENDPOINT=s3.domain.com
# S3_USE_SSL=true

# Define a global apikey to access all instances.
# OBS: This key must be inserted in the request header to create an instance.
ENV AUTHENTICATION_API_KEY=BuyApp@00112233
# If you leave this option as true, the instances will be exposed in the fetch instances endpoint.
ENV AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES=true
ENV LANGUAGE=en

ENTRYPOINT ["/bin/bash", "-c", "./Docker/scripts/deploy_database.sh && npm run start:prod" ]