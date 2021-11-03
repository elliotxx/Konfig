import base.pkg.kusion_kubernetes.api.core.v1 as kubev1
import base.pkg.kusion_kubernetes.apimachinery.apis
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.frontend.volume
import base.pkg.kusion_models.kube.frontend.resource as res
import base.pkg.kusion_models.kube.frontend.sidecar as s
import base.pkg.kusion_models.kube.templates.resource as res_tpl
import base.pkg.kusion_models.kube.metadata

schema Server:
    __settings__:{str:str} = {"output_type" = "IGNORE"}

    # Application workload type, default to 'Deployment'
    workloadType: "Deployment" = "Deployment"

    # Application replicas
    replicas: int = option("replicas") or 1

    # Main container image
    image: str = option("image")
    # Main container resource
    resource: res.Resource | res.ResourceRequirements = res_tpl.small
    # Release strategy
    # releaseStrategy: str = "Percent"

    # Main container configuration
    mainContainer: container.Main
    # Sidecar container configurations
    sidecarContainers?: [s.Sidecar]
    # Init container configurations
    initContainers?: [s.Sidecar]

    # Workload configuration
    name: str = metadata.__META_APP_NAME
    namespace: str = name
    labels?: {str:str}
    annotations?: {str:str}
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

    # Other configurations
    needNamespace?: bool = False
    autoSelector?: bool = True


    # TODO:
    # configMaps?: [v1.ConfigMap]
    # secrets?: [v1.Secret]
    # services?: [v1.Service]
    # ingresses?: [v1.Ingress]
