import base.pkg.kusion_kubernetes.api.core.v1 as kubev1
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.templates.resource as res_tpl

schema Server:
    __settings__:{str:str} = {"output_type" = "IGNORE"}

    # 应用工作负载类型，默认使用Deployment
    workloadType: "Deployment" = "Deployment"
    # workload 元数据
    name: str = metadata.__META_APP_NAME
    namespace: str = name
    labels?: {str:str}
    annotations?: {str:str}
    # 应用实例数
    replicas: int = option("replicas") or 1
    # 主容器镜像
    image: str = option("image")
    # 主进程容器资源规格
    resource: res.Resource | res.ResourceRequirements = res_tpl.small
    # 发布策略
    # releaseStrategy: str = "Percent"

    # 主进程容器
    mainContainer: container.Main
    # Sidecar 容器配置
    sidecarContainers?: [s.Sidecar]
    # 初始化容器配置
    initContainers?: [s.Sidecar]

    # workload spec 属性
    selector?: {str:str}
    podMetadata?: apis.ObjectMeta
    volumes?: [volume.Volume]

    dnsConfig?: kubev1.PodDNSConfig
    dnsPolicy?: "ClusterFirstWithHostNet" | "ClusterFirst" | "Default" | "None" = "ClusterFirst"
    serviceAccountName?: str
    hostNetwork?: bool
    restartPolicy?: str
    terminationGracePeriodSeconds?: int
    progressDeadlineSeconds?: int
    minReadySeconds?: int
    readinessGates?: [kubev1.PodReadinessGate]
    securityContext?: {str:}
    shareProcessNamespace?: bool
    containerRuntime?: str

    # 是否需要新建Namespace
    needNamespace?: bool = False

    configMaps?: [v1.ConfigMap]
    secrets?: [v1.Secret]
    services?: [v1.Service]
    ingresses?: [v1.Ingress]

