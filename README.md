# programming-deploy

Repository này cho phép deploy 1 challenge programming được build từ Docker

## 1. Docker
Là một nền tảng để cung cấp cách để building, deploying và running ứng dụng dễ dàng hơn bằng cách sử dụng các containers (trên nền tảng ảo hóa).

![](https://i.imgur.com/bQxmYZA.png)

Vì mỗi project mình có thể setup ở một môi trường riêng, nên các challenge sẽ không bị xung đột, chia sẻ tài nguyên tối ưu. Từ đó giảm thiểu tối đa sự phụ thuộc lẫn nhau, cài đặt, thêm bớt sửa xóa các thư viện, cấu hình cũng sẽ không bị ảnh hưởng tới các challenge khác.
### Cấu trúc thư mục:
```bash
.
├── Dockerfile
├── README.md
└── dir
    ├── ELF
    └── flag.txt
```
`Dockerfile`:  tệp tin chỉ dẫn, cấu hình để build challenge
```Dockerfile
# Xây dựng một docker image mới từ ubuntu 18.04
FROM ubuntu:18.04

# Update các packages cần thiết
RUN apt-get update --fix-missing

# Install package socat
RUN apt -y install socat

# Tạo group mới
RUN groupadd ctf

#Tạo folder mới
RUN mkdir /chall

# Copy tất cả các file từ folder dir của source code sang folder chall của image
COPY ./dir /chall

# Tạo user, mặc định cho group ban đầu, dẫn thư mục ~ của user tới folder chall
RUN useradd -G ctf --home=/chall revuser
RUN useradd -G ctf --home=/chall revflag

# Tạo quyền cho file

# Owner, Group, Other can read, execute
# Owner can write
RUN chmod 4755 /chall/ELF

# Owner, Group can read
RUN chmod 440 /chall/flag.txt

# Lắng nghe kết nối từ cổng docker (không NAT port từ host vào container được)
EXPOSE 8189
# Lệnh khởi động khi Container chạy
CMD ["su", "-c", "exec socat TCP-LISTEN:8189,reuseaddr,fork EXEC:/chall/ELF,stderr", "-", "revuser"]

```
`.dockerignore`:  sinh ra với mục đích báo cho docker biết để loại trừ những file này ra khỏi quá trình build image.

```txt
Dockerfile
README.md
```
`dir`: Thư mục chứa source ta cần trong quá trình build image.
`dir/ELF`: là file thực thi người dùng lắng nghe port từ netcat
`dir/flag.txt`: là file chứa flag (không quan trọng lắm).

## 2. Socat
(Google vì mình cũng không hiểu cái này lắm :'()
From chị Ly

### Lưu ý:
Bắt buộc phải có
```C
...
void ignore_me_init_buffering() {
	setvbuf(stdout, NULL, _IONBF, 0);
	setvbuf(stdin, NULL, _IONBF, 0);
	setvbuf(stderr, NULL, _IONBF, 0);
}
...
int main() {
    ignore_me_init_buffering();
...
}
```

`ELF` file được build từ gcc hoặc Makefile có standard (hoặc tương tự):

```
ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, not stripped
```

## How to use:
Build image:
```bash
docker -build -t challenge01 .
```
Run container:
```bash
docker run -it --rm -d -p 8289:8289 challenge01
```
Lưu ý tham số -p <`port của hệ thống`>:<`port của container`>
Port hệ thống là port được pushlish để truy cập netcat
Port của container được cấu hình trong file `Dockerfile`
Nếu muốn thay đổi, có thể sửa dòng:
```Dockerfile
# PORT EXPOSE
EXPOSE 8289
# PORT  tcp-listen
CMD ["su", "-c", "exec socat TCP-LISTEN:8289,reuseaddr,fork EXEC:/chall/ELF,stderr", "-", "revuser"]
```

Here we go: 
```bash
nc 127.0.0.1 8289
```

