import base.pkg.kusion_models.kube.utils

schema relaxed InitContainersMixin:
    assert data, "data must be specified and can't be empty or None or Undefined"

    if data.initContainers:
        # Construct mixin result
        __initContainers = [utils.ContainerFrontend2Kube(_s).result for _s in data.initContainers]