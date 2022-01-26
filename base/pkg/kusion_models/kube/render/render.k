import base.pkg.kusion_models.kube.frontend
import base.pkg.kusion_models.kube.backend

__renderServerFrontendInstances__ = [inst for inst in frontend.Server.instances() if typeof(inst) == "Server"]
__renderServerBackendInstances__ = [backend.ServerBackend(inst) for inst in __renderServerFrontendInstances__]

__renderFrontendInstances__ = [
    *__renderServerFrontendInstances__
]
__renderBackendInstances__ = [
    *__renderServerBackendInstances__
]

renderKubeKubernetes = [
    _inst?.kubernetes | {__settings__: {output_type = "STANDALONE"}} \
    for _inst in __renderBackendInstances__ if _inst?.kubernetes
]
