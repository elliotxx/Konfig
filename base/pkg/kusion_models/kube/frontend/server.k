import base.pkg.kusion_kubernetes.api.core.v1 as kubev1
import base.pkg.kusion_kubernetes.apimachinery.apis
import base.pkg.kusion_models.kube.frontend.configmap
import base.pkg.kusion_models.kube.frontend.secret
import base.pkg.kusion_models.kube.frontend.service
import base.pkg.kusion_models.kube.frontend.ingress
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.frontend.volume
import base.pkg.kusion_models.kube.frontend.resource as res
import base.pkg.kusion_models.kube.frontend.sidecar as s
import base.pkg.kusion_models.kube.frontend.strategy
import base.pkg.kusion_models.kube.metadata

schema Server:
    __settings__:{str:str} = {"output_type" = "IGNORE"}

    # Application workload type, default to 'Deployment'
    workloadType: "Deployment" | "StatefulSet" = "Deployment"

    # Application replicas
    replicas: int = option("replicas") or 1

    # Main container image
    image: str = option("image")
    # Main container resource
    schedulingStrategy: strategy.SchedulingStrategy = strategy.SchedulingStrategy{}

    # Main container configuration
    mainContainer: container.Main
    # Sidecar container configurations
    sidecarContainers?: [s.Sidecar]
    # Init container configurations
    initContainers?: [s.Sidecar]

    # Workload configuration
    labels?: {str:str}
    annotations?: {str:str}
    selector?: {str:str}
    podMetadata?: apis.ObjectMeta
    volumes?: [volume.Volume]

    # Other configurations
    needNamespace?: bool = True

    configMaps?: [configmap.ConfigMap]
    secrets?: [secret.Secret]
    services?: [service.Service]
    ingresses?: [ingress.Ingress]
