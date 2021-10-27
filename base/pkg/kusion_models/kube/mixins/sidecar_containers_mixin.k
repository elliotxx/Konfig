import base.pkg.kusion_models.kube.utils

schema relaxed SidecarContainersMixin:
    assert data, "data must be specified and can't be empty or None or Undefined"

    if data.sidecarContainers:
        # Construct mixin result
        __sidecarContainers = [utils.ContainerFrontend2Kube(_s).result for _s in data.sidecarContainers]