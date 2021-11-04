import base.pkg.kusion_kubernetes.api.core.v1
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema relaxed SecretMixin:
    if data.secrets:
        __kubeSecrets = [ v1.Secret {
            metadata: {
                **utils.MetadataBuilder(_s).result
                name = _s?.name or "{}{}{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME, _i)
            }
            data: _s?.data
            stringData: _s?.stringData
            type: _s?.type
        } for _i,_s in data.secrets]

        _kubernetes |= {
            if __kubeSecrets:
                "${__kubeSecrets?[0].kind}": __kubeSecrets
        }