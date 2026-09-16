# Stage 1: Build
FROM swift:5.9-focal AS build
WORKDIR /build
COPY . .
RUN swift build -c release

# Stage 2: Run
FROM swift:5.9-focal-slim
WORKDIR /app
COPY --from=build /build/.build/release/App /app/App
# ก๊อปปี้โฟลเดอร์ Public เข้าไปด้วยเพื่อให้เว็บแสดงรูปได้
COPY --from=build /build/Public /app/Public

EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
