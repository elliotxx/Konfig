# 前言
> 本 README.md 包括配置代码仓库目录/文件说明及如何本地使用 Kusion+Minikube 进行测试

## 快速开始
1. [安装 Kusion](https://yuque.antfin.com/zupxpu/bwyd90/yo222g)，在任意命令行中执行下述命令：  
```bash
# 执行安装脚本
wget http://antsys-kusion-dev.cn-hangzhou-alipay-b.oss-cdn.aliyun-inc.com/scripts/install_kusion.sh -qO - | bash
# 验证安装结果
kusion --help
kcl --help
```
2. 查看应用目录 base/base.k 和 test/main.k 文件中的配置是否符合预期，如果不符合预期，可自行修改  
```bash
# 进入应用目录
cd demo
# 查看应用配置
cat base/base.k 
cat test/main.k 
```
3. 编译（编译 .k 文件，生成 YAML）
```bash
cd test/ci-test
make
# 查看编译结果
cat stdout.golden.yaml
```
4. 集群测试：使用 kusionCtl 将 test/main.k 一键拍到 minikube 本地集群中
```bash
# test.kubeconfig 需要替换为测试集群的证书
export KUBECONFIG=test.kubeconfig

# 部署到集群
make deploy

# 查看拍到集群中的资源
kubectl get deployment -n demo
kubectl get namespace

# 删除拍到集群中的资源
make undeploy
```
## 目录和文件说明
```bash
.
├── base                        // 各环境通用配置
│   ├── base.k
├── prod                        // 环境目录
│   └── ci-test                 // ci 测试目录，放置测试脚本和数据
│     └── Makefile              // 测试脚本
│     └── settings.yaml         // 测试数据和编译文件配置
│     └── stdout.golden.yaml    // 期望的 YAML，可通过 make 更新
│   └── main.k                  // 应用在当前环境的配置清单
│   └── stack.yaml
└── project.yaml	// 应用基础信息
└── README.md                   // 说明文档
```
