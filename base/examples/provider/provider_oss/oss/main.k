import base.pkg.kusion_models.commons

# _bucket = oss.Bucket{
#     ossUser = "default" #固定default
#     bucketName = "buckethuanyutest" #需要创建的bucket名
#     app = "thuanyu" #应用名
#     bucketAcl = "private" #bucket读写类型 private/public-read/public-read-write
#     storageClass = "Standard" #bucket存储类型：Standard/IA/Archive/ColdArchive
#     drOption = "无需容灾" #容灾选项：标准型//流水型/无需容灾
#     presetQuota = 100 #预估占用容量，单位为GB
#     endpoint= "oss-cn-hohhot-ste3-d01-a.ops.ste3.com" #使用这个endpoint创建bucket，需要找管理员要可以传空字符串
#     creator = "bootstrap" #固定创建人
# }

_bucket = {
    "bucket" = "kusion-test-bucket"
    "acl"    = "private"
}

# 以下内容可以直接copy
isee_bucket = commons.ProviderResourceBuilder {
    name: "bucket1"
    type: "alicloud_oss_bucket"
    provider: {
        host: "registry.terraform.io"
        namespace: "aliyun"
        name: "alicloud"
        version: "1.153.0"
    }
    instances: [
        commons.Instance {
            data: _bucket 
        }
    ]
}.result