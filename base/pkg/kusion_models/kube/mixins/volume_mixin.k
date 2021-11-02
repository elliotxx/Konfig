import base.pkg.kusion_models.kube.metadata

schema relaxed VolumeMixin:
    assert data, "data must be specified and can't be empty or None or Undefined"

    if data.volumes:
        __mainContainer |= {
            volumeMounts = sum([[
                {
                    name: _volume.name
                    mountPath: _mount.path
                    subPath: _mount.subPath
                    readOnly: _mount.readOnly or Undefined
                } for _mount in _volume.mounts if _mount.container == __mainContainer.name or _mount.container == "*" 
            ] for _volume in data.volumes ], [])
        } if __mainContainer else Undefined

        __sidecarContainers = [
            _container | {
                volumeMounts = sum([[
                    {
                        name: _volume.name
                        mountPath: _mount.path
                        subPath: _mount.subPath
                        readOnly: _mount.readOnly or Undefined
                    } for _mount in _volume.mounts if _mount.container == _container.name or _mount.container == "*"
                ] for _volume in data.volumes ], [])
            } for _container in __sidecarContainers
        ] if __sidecarContainers else Undefined

        __initContainers = [
            _container | {
                volumeMounts = sum([[
                    {
                        name: _volume.name
                        mountPath: _mount.path
                        subPath: _mount.subPath
                        readOnly: _mount.readOnly or Undefined
                    } for _mount in _volume.mounts if _mount.container == _container.name or _mount.container == "*"
                ] for _volume in data.volumes ], [])
            } for _container in __initContainers
        ] if __initContainers else Undefined