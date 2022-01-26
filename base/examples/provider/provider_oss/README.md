# 前言
## 快速开始
```bash
$ cd oss
$ kusion apply
SUCCESS  Compiling in stack dev...

Stack: oss  Provider                        Type            Name    Plan
      * ├─  alicloud         alicloud_oss_bucket      bucket-acl  Create
      * └─  alicloud  alicloud_oss_bucket_object  object-content  Create

✔ yes
Start applying diffs......
SUCCESS: Create <alicloud, alicloud_oss_bucket, bucket-acl> success
SUCCESS: Create <alicloud, alicloud_oss_bucket_object, object-content> success

Creating <alicloud, alicloud_oss_bucket_object, object-content> [2/2] ████████████████████████████████ 100% | 0s

Apply complete! Resources: 2 created, 0 updated, 0 deleted.

$ wget https://kusion-bucket-acl.oss-cn-beijing.aliyuncs.com/kusion-testdata.txt 
$ cat kusion-testdata.txt
```

## 目录和文件说明
```bash
.
├── base                        // 各环境通用配置
│   ├── base.k                  // 应用的环境通用配置
├── prod                        // 环境目录
│   └── ci-test                 // ci 测试目录，放置测试脚本和数据
│     └── settings.yaml         // 测试数据和编译文件配置
│     └── stdout.golden.yaml    // 期望的 YAML，可通过 make 更新
│   └── kcl.yaml                // 当前 Stack 的多文件编译配置
│   └── main.k                  // 应用在当前环境的配置清单
│   └── stack.yaml              // Stack 元信息
└── project.yaml	            // Project 元信息
└── README.md                   // 说明文档
```
