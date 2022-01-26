import base.pkg.kusion_kubernetes.api.networking.v1 as networking_v1
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema relaxed IngressMixin:
    if data.ingresses:
        __kubeIngresses = [ networking_v1.Ingress {
            metadata: utils.MetadataBuilder(_s) | {
                name = _s?.name or "{}{}{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME, _i)
            }
            spec: {
                rules: _s?.rules
            }
        } for _i,_s in data.ingresses]

        _kubernetes |= {
            if __kubeIngresses:
                "${__kubeIngresses?[0].kind}": __kubeIngresses
        }