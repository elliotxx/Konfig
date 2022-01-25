schema Bucket:
    ossUser?: str #oss账号，在数据库中配置，如果不知道配置，会使用default
    bucketName: str
    app: str
    bucketAcl: str  #private, public-read, public-read-write
    storageClass: str #Standard（默认值）：标准存储; IA：低频访问; Archive：归档存储; ColdArchive：冷归档存储
    drOption: str #容灾选项：标准型; 流水型; 无需容灾
    presetQuota: int
    endpoint: str #使用这个endpoint创建bucket，需要找管理员要, 可以传空字符串
    creator: str
