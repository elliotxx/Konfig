import base.pkg.kusion_kubernetes.api.core.v1
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema relaxed ConfigMapMixin:
    if data.configMaps:
        __kubeConfigMaps = [ v1.ConfigMap {
            metadata: {
                **utils.MetadataBuilder(_c).result
                name = "{}{}{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME, _i)
            }
            data: _c?.data
            binaryData: _c?.binaryData
        } for _i,_c in data.configMaps ]

        _kubernetes |= {
            if __kubeConfigMaps:
                "${__kubeConfigMaps?[0].kind}": __kubeConfigMaps
        }