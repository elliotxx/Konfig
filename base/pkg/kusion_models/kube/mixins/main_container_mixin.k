import base.pkg.kusion_kubernetes.api.core.v1 as kubev1
import base.pkg.kusion_models.kube.utils

schema relaxed MainContainerMixin:
    assert data, "data must be specified and can't be empty or None or Undefined"

    __mainContainer?: {str:}

    if data.mainContainer:
        assert data.image, "data.image must be specified and can't be empty or None or Undefined"
        assert data.resource, "data.resource must be specified and can't be empty or None or Undefined"

        # Construct input of converter
        _mainContainerDict = {
            **{k:v for k,v in data.mainContainer}
            env += __application_envs
            name = data.mainContainer.name or "main"
            image = data.image
            resource = data.resource
        }

        # Construct mixin result
        __mainContainer = utils.ContainerFrontend2Kube(_mainContainerDict).result