import base.pkg.kusion_kubernetes.api.core.v1
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema relaxed ServiceMixin:
    if data.services:
        assert "workloadType" in data, "data must contain `workloadType` attribute"

        __workloadSelector = _kubernetes?[data.workloadType]?[0]?.spec?.selector?.matchLabels

        __kubeServices = [ v1.Service {
            metadata: {
                **utils.MetadataBuilder(_s).result
                name = _s?.name or "{}{}{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME, _i)
            }
            spec: {
                clusterIP: _s?.clusterIP if _s?.type in ["ClusterIP", "NodePort", "LoadBalancer", None, Undefined] else Undefined
                externalIPs: _s?.externalIPs
                externalName: _s?.externalName if _s?.type == "ExternalName" else Undefined
                externalTrafficPolicy: _s?.externalTrafficPolicy
                healthCheckNodePort: _s?.healthCheckNodePort if _s?.type == "LoadBalancer" and _s?.externalTrafficPolicy == "Local" else Undefined
                ipFamilyPolicy: _s?.ipFamilyPolicy
                loadBalancerIP: _s?.loadBalancerIP if _s?.type == "LoadBalancer" else Undefined
                loadBalancerSourceRanges: _s?.loadBalancerSourceRanges
                ports: _s?.ports
                publishNotReadyAddresses: _s?.publishNotReadyAddresses
                selector: _s?.selector
                sessionAffinity: _s?.sessionAffinity
                sessionAffinityConfig: _s?.sessionAffinityConfig if _s?.sessionAffinity == "ClientIP" else Undefined
                type: _s?.type
            }
        } for _i,_s in data.services]

        _kubernetes |= {
            if __kubeServices:
                "${__kubeServices?[0].kind}": __kubeServices
        }