FROM node AS bundler
WORKDIR /worker
COPY . .

RUN yarn install
RUN npx webpack --mode production

FROM swift AS builder

WORKDIR /worker
COPY --from=bundler /worker .

RUN swift build -c release

RUN mkdir app && cp -r "$(swift build -c release --show-bin-path)" app/

FROM swift:slim

WORKDIR /app
COPY --from=builder /worker/app .

EXPOSE 8080

ENTRYPOINT ["./release/Server"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
