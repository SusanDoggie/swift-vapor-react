FROM node AS bundler
WORKDIR /worker
COPY . .

RUN yarn install
RUN npx webpack --mode production

FROM swift AS builder

WORKDIR /worker
COPY --from=bundler /worker .

RUN swift build -c release \
 && mkdir app && cp -r "$(swift build -c release --show-bin-path)" app/ \
 && cd app \
 && rm -rf *.build \
 && rm -rf *.swiftdoc \
 && rm -rf *.swiftmodule \
 && rm -rf *.swiftsourceinfo \
 && rm -rf *.product \
 && rm -rf ModuleCache \
 && rm -f description.json

FROM swift:slim

WORKDIR /app
COPY --from=builder /worker/app .

EXPOSE 8080

ENTRYPOINT ["./release/Server"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
