# minio
размер стореджа по самому маленькому диску!!!

docker run -d -p 9001:9000 -e "MINIO_ACCESS_KEY=KM9IL4OSS15P0H2TMWPP" -e "MINIO_SECRET_KEY=RQQny9tMVNg0uv1AbVSmykkINhe86UpEgRq+TWLV" -v /data/minio-data:/data -d minio/minio server /data

https://github.com/minio/minio
