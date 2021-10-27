import sigma.base.pkg.kusion_models.core.v1
import sigma.base.pkg.kusion_models.app_configuration as ac

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

    # 该 Mixin 的作用是根据 data 中的属性，生成 Kubernetes 资源，并存放到 kubernetes 属性中
    # 如果以下必须属性在主体中不存在，那么动态生成
    _kubernetes: {str:[]}

    if data.needNamespace:
        _kubeNamespace = (v1.Namespace {
            # 生效优先级：name in stack.yaml > globalAppName
            name: ac.__META_STACK_NAME or ac.__META_GLOBAL_APP_NAME
        }).kubernetes

        _kubernetes |= {
            "${_kubeNamespace.kind}": [
                _kubeNamespace
            ]
        }
