schema SchedulingStrategy:
    """ SchedulingStrategy represents scheduling strategy.

    Attributes
    ----------
    resource: str, default is "1<cpu<2,1Gi<memory<2Gi,disk=20Gi", required.
        A Pod-level attribute.
        Main container resource.
    """
    resource: str = "1<cpu<2,1Gi<memory<2Gi,disk=20Gi"