import base.pkg.kusion_models.kube.metadata

schema relaxed VolumeMixin:
    assert data, "data must be specified and can't be empty or None or Undefined"

    if data.volumes:
        _mainContainer |= {
            volumeMounts = sum([[
                {
                    name: _volume.name
                    mountPath: _mount.path
                    subPath: _mount.subPath
                    readOnly: _mount.readOnly or Undefined
                } for _mount in _volume.mounts if _mount.container == _mainContainer.name or _mount.container == "*" 
            ] for _volume in data.volumes ], [])
        } if _mainContainer else Undefined

        _sidecarContainers = [
            _container | {
                volumeMounts = sum([[
                    {
                        name: _volume.name
                        mountPath: _mount.path
                        subPath: _mount.subPath
                        readOnly: _mount.readOnly or Undefined
                    } for _mount in _volume.mounts if _mount.container == _container.name or _mount.container == "*"
                ] for _volume in data.volumes ], [])
            } for _container in _sidecarContainers
        ] if _sidecarContainers else Undefined

        _initContainers = [
            _container | {
                volumeMounts = sum([[
                    {
                        name: _volume.name
                        mountPath: _mount.path
                        subPath: _mount.subPath
                        readOnly: _mount.readOnly or Undefined
                    } for _mount in _volume.mounts if _mount.container == _container.name or _mount.container == "*"
                ] for _volume in data.volumes ], [])
            } for _container in _initContainers
        ] if _initContainers else Undefined