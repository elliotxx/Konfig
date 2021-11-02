import base.pkg.kusion_kubernetes.api.apps.v1 as appsv1
import base.pkg.kusion_models.kube.frontend.server
import base.pkg.kusion_models.kube.mixins

schema ServerBackend[inputData]:
    mixin [
        # resource mixin
        # mixins.ConfigMapMixin
        # mixins.SecretMixin
        # mixins.ServiceMixin
        mixins.NamespaceMixin,
        mixins.MetadataMixin,
        mixins.MainContainerMixin,
        mixins.SidecarContainersMixin,
        mixins.InitContainersMixin,
        # mixins.VolumesMixin

        # biz mixin
        mixins.ApplicationMixin,
        mixins.OutputTypeMixin
    ]
    
    data: server.Server = inputData
    kubernetes: {str:[any]} = {}

    # Validations
    # TODO

    # Construct workload attributes
    _workload_attributes: {str:} = {
        metadata: __metadata
        spec: {
            replicas: data.replicas
            selector: {
                matchLabels: {
                    **__application_selector
                    **data.selector
                }
            }
            template: {
                metadata: {
                    labels: {
                        **__application_labels
                    }
                    **data.podMetadata
                }
                spec: {
                    containers: [
                        __mainContainer
                        __sidecarContainers
                    ]
                    initContainers: __initContainers
                    serviceAccount: data.serviceAccountName
                    hostNetwork: data.hostNetwork
                    restartPolicy: data.restartPolicy
                    terminationGracePeriodSeconds: data.terminationGracePeriodSeconds
                    readinessGates: data.readinessGates
                    securityContext: data.securityContext
                    shareProcessNamespace: data.shareProcessNamespace
                    runtimeClassName: data.containerRuntime
                    dnsConfig: data.dnsConfig
                    dnsPolicy: data.dnsPolicy
                }
            }
            progressDeadlineSeconds: data.progressDeadlineSeconds
            minReadySeconds: data.minReadySeconds
        }
    }

    # Generate workload instance
    if data.workloadType == "Deployment":
        _workloadInstance = appsv1.Deployment {**_workload_attributes}

    # Put workload instance to backend result
    _kubernetes: {str:[any]} = {
        if _workloadInstance:
            "${typeof(_workloadInstance)}": [_workloadInstance]
    }