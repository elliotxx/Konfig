import base.pkg.kusion_models.kube.frontend.container.probe as p
import base.pkg.kusion_models.kube.frontend.container.env as e
import base.pkg.kusion_models.kube.frontend.container.port as cp
import base.pkg.kusion_models.kube.frontend.container.lifecycle as lc
import base.pkg.kusion_models.kube.frontend.resource as res

schema Sidecar:
    """ Sidecar describes the sidecar container configuration that is expected to be run on the host.

    Attributes
    ----------
    name: str, default is Undefined, required.
        A Container-level attribute.
        The container name. Each container in a pod must have a unique name.
    command: [str], default is Undefined, optional.
        A Container-level attribute.
        The startup command of main process. The image's entrypoint is used if this is not provided.
    args: [str], default is Undefined, optional.
        A Container-level attribute.
        The startup arguments of main process. The image's cmd is used if this is not provided.
    env: [e.Env], default is Undefined, optional.
        A Container-level attribute.
        List of environment variables in the container.
    livenessProbe: p.Probe, default is Undefined, optional.
        A Container-level attribute.
        The probe to check whether container is live or not.
    readinessProbe: p.Probe, default is Undefined, optional.
        A Container-level attribute.
        The probe to check whether container is ready or not.
    startupProbe: p.Probe, default is Undefined, optional.
        A Container-level attribute.
        The probe to indicates that the Pod has successfully initialized.

    Examples
    --------
    import base.pkg.kusion_models.kube.frontend.sidecar as s
    import base.pkg.kusion_models.kube.frontend.container.probe as p

    sidecar = s.Sidecar {
        name: "test"
        livenessProbe: p.Probe {
            handler: p.Http {
                httpPath: "/healthz"
            }
            initialDelaySeconds: 10
        }
    }
    """

    name:            str
    command?:        [str]
    args?:           [str]
    env?:            [e.Env]
    envFrom?:        [e.EnvFromSource]
    ports?:          [cp.ContainerPort]
    resource:        res.Resource | res.ResourceRequirements
    image:           str

    readinessProbe?: p.Probe
    livenessProbe?:  p.Probe
    startupProbe?:   p.Probe

    lifecycle?:      lc.Lifecycle
    workingDir?:     str
    securityContext?:{str:}

    check:
        livenessProbe.successThreshold == 1 if livenessProbe, "success threshold must be 1 for liveness probe"
