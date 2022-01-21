import base.pkg.kusion_kubernetes.api.core.v1
import base.pkg.kusion_models.kube.metadata
import base.pkg.kusion_models.kube.utils

schema relaxed SchedulingStrategyMixin:
    """SchedulingStrategyMixin encapsulate the scheduling strategy mixin.

    Attributes
    ----------
    schedulingStrategy: SchedulingStrategy, default is SchedulingStrategy{}, required.
        A Server-level attribute.

    Examples
    --------
    app: {
        schedulingStrategy: SchedulingStrategy {
            resource = "1<cpu<2,1Gi<memory<2Gi,disk=20Gi"
        }
    }
    """

    if data?.schedulingStrategy?.resource:
        __kubeResourceRequirements = utils.Str2ResourceRequirements(data.schedulingStrategy.resource).result
