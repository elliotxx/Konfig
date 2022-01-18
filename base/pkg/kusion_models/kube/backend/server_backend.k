import base.pkg.kusion_kubernetes.api.apps.v1 as appsv1
import base.pkg.kusion_kubernetes.api.core.v1 as corev1
import base.pkg.kusion_models.kube.frontend.server
import base.pkg.kusion_models.kube.mixins
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema ServerBackend[inputData]:
    mixin [
        # Resource builder mixin
        mixins.NamespaceMixin,
        mixins.ConfigMapMixin,
        mixins.SecretMixin,
        mixins.ServiceMixin,

        # Workload builder mixin
        mixins.VolumeMixin,
        mixins.SchedulingStrategyMixin,

        # Biz mixin
        mixins.ApplicationMixin,
        mixins.OutputTypeMixin
    ]
    
    data: server.Server = inputData
    kubernetes: {str:[any]} = {}

    # Validations
    # TODO

    # Varaible
    _workload_name: str = "{}{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME).lower()

    # Logic
    if data.mainContainer:
        assert data.image, "data.image must be specified and can't be empty or None or Undefined"
        # Construct input of converter
        _mainContainerDict = {
            **{k:v for k,v in data.mainContainer}
            env += __application_envs
            name = data.mainContainer.name or "main"
            image = data.image
            resource = data?.schedulingStrategy?.resource
        }
        _mainContainer = utils.ContainerFrontend2Kube(_mainContainerDict).result

    if data.sidecarContainers:
        _sidecarContainers = [utils.ContainerFrontend2Kube(_s).result for _s in data.sidecarContainers]

    if data.initContainers:
        _initContainers = [utils.ContainerFrontend2Kube(_s).result for _s in data.initContainers]

    # Construct workload attributes
    _workload_attributes: {str:} = {
        metadata: {
            **utils.MetadataBuilder(data).result
            name = _workload_name
        }
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
                        _mainContainer
                        *_sidecarContainers
                    ]
                    initContainers: _initContainers
                    volumes: [
                        {
                            name: _volume.name
                            "${_volume.volumeSource._type}": {} if _volume.volumeSource._type == "emptyDir" and _volume.volumeSource.medium == "" else _volume.volumeSource
                        } for _volume in data.volumes if _volume.volumeSource
                    ] if data.volumes else Undefined
                }
            }
        }
    }

    # Generate workload instance
    if data.workloadType == "Deployment":
        _workloadInstance = appsv1.Deployment {**_workload_attributes}
    elif data.workloadType == "StatefulSet":
        # Generate default headless service of StatefulSet
        _headlessServiceInstance = corev1.Service {
            metadata: _workload_attributes.metadata
            spec: {
                clusterIP: "None"
                selector: _workload_attributes.spec.selector.matchLabels
            }
        }
        _workloadInstance = appsv1.StatefulSet {
            **_workload_attributes
            spec: {
                serviceName: _headlessServiceInstance.metadata.name
            }
        }

    # Put workload instance to backend result
    _kubernetes: {str:[any]} = {
        if _workloadInstance:
            "${typeof(_workloadInstance)}": [_workloadInstance]
        if _headlessServiceInstance:
            "${typeof(_headlessServiceInstance)}": [_headlessServiceInstance]
    }