import regex

schema Resource:
    """ Resource describes the compute resource requirements.

    Attributes
    ----------
    cpu: str, default is "1", required.
        A Container-level attribute.
        CPU, in cores, default 1 core. (500m = .5 cores)
    memory: str, default is "1024Mi", required.
        A Container-level attribute.
        Memory, in bytes, default 1024Mi. (500Gi = 500GiB = 500 * 1024 * 1024 * 1024)
    disk: str, default is "10Gi", required.
        A Container-level attribute.
        Local disk storage, in bytes, default 10Gi. (500Gi = 500GiB = 500 * 1024 * 1024 * 1024)
    epchygontee?: str, default is Undefined, optional.
        A Container-level attribute.
        EPC resource of hygon TEE, in Gi bytes, empty or "0" means don't need this resource

    Examples
    --------
    import base.pkg.kusion_models.kube.frontend.resource as res

    res = res.Resource {
        cpu =    "2"
        memory = "2048Mi"
        disk =   "20Gi"
    }
    """

    cpu?:           str = "1"
    memory?:        str = "1024Mi"
    disk?:          str = "10Gi"
    check:
        regex.match(cpu, r"^([+-]?[0-9.]+)([m]*[-+]?[0-9]*)$") if cpu, "cpu must match specific regular expression"
        regex.match(memory, r"^([0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if memory, "memory must match specific regular expression"
        regex.match(disk, r"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if disk, "disk must match specific regular expression"
