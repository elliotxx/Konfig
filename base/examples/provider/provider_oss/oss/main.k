import base.pkg.kusion_models.commons

_bucket_acl = {
    bucket = "kusion-bucket-acl6"
    acl    = "private"
}

# _bucket_website = {
#     bucket = "kusion-bucket-website6"
#     website = [
#         {
#             index_document = "index.html"
#             error_document = "error.html"
#         }
#     ]
# }

# _bucket_object = {
#     bucket  = _bucket_acl.bucket
#     key     = "new_object_key.txt"
#     content = "the content that you want to upload."
# }

# 以下内容可以直接copy
result = commons.ProviderResourceBuilder {
    name: "bucket-acl"
    type: "alicloud_oss_bucket"
    provider: {
        host: "registry.terraform.io"
        namespace: "aliyun"
        name: "alicloud"
        version: "1.153.0"
    }
    instances: [
        commons.Instance {
            data: _bucket_acl 
        }
    ]
}.result

# result2 = commons.ProviderResourceBuilder {
#     name: "bucket-website"
#     type: "alicloud_oss_bucket"
#     provider: {
#         host: "registry.terraform.io"
#         namespace: "aliyun"
#         name: "alicloud"
#         version: "1.153.0"
#     }
#     instances: [
#         commons.Instance {
#             data: _bucket_website 
#         }
#     ]
# }.result

# result3 = commons.ProviderResourceBuilder {
#     name: "object-content"
#     type: "alicloud_oss_bucket_object"
#     provider: {
#         host: "registry.terraform.io"
#         namespace: "aliyun"
#         name: "alicloud"
#         version: "1.153.0"
#     }
#     instances: [
#         commons.Instance {
#             data: _bucket_object 
#             # dependsOn: [
#             #     "registry.terraform.io/aliyun/alicloud.alicloud_oss_bucket.bucket-acl[0]"
#             # ]
#         }
#     ]
# }.result