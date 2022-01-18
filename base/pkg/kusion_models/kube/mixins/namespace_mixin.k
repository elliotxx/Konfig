import base.pkg.kusion_kubernetes.api.core.v1
import base.pkg.kusion_models.kube.metadata

schema relaxed NamespaceMixin:
    """NamespaceMixin encapsulate the logic of automatically creating a 
    namespace resource.

    Attributes
    ----------
    needNamespace: bool, default is False, optional.
        A Server-level attribute.
        Represents whether a namespace needs to be created.
        If not specified, default to False.

    Examples
    --------
    app: {
        needNamespace: True
    }
    """

    if data.needNamespace:
        __kubeNamespace = v1.Namespace {
            metadata: {
                name: metadata.__META_APP_NAME
            }
        }

        _kubernetes |= {
            "${__kubeNamespace.kind}": [
                __kubeNamespace
            ]
        }
