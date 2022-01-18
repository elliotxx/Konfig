import regex

schema Str2ResourceRequirements[resourceStr]:
    __scheduling_resource_items = resourceStr.split(",")

    __kubeResourceRequirements = [{
        "cpu": {
            "requests":  (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[0])?.strip()
            "limits": (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[-1])?.strip()
        }
    } if "cpu" in _item else ({
        "memory": {
            "requests": (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[0])?.strip()
            "limits": (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[-1])?.strip()
        }
    } if "memory" in _item else ({
        "disk": {
            "requests": (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[0])?.strip()
            "limits": (_item.split("=")?[1] if len(_item.split("=")) > 1 else _item.split("<")?[-1])?.strip()
        }
    } if "disk" in _item else Undefined)) for _item in __scheduling_resource_items]

    __kubeResourceRequirements = {
        "requests": {
            "cpu": __kubeResourceRequirements?[0]?.cpu?.requests or __kubeResourceRequirements?[1]?.cpu?.requests or __kubeResourceRequirements?[2]?.cpu?.requests
            "memory": __kubeResourceRequirements?[0]?.memory?.requests or __kubeResourceRequirements?[1]?.memory?.requests or __kubeResourceRequirements?[2]?.memory?.requests
            "ephemeral-storage": __kubeResourceRequirements?[0]?.disk?.requests or __kubeResourceRequirements?[1]?.disk?.requests or __kubeResourceRequirements?[2]?.disk?.requests
        }
        "limits": {
            "cpu": __kubeResourceRequirements?[0]?.cpu?.limits or __kubeResourceRequirements?[1]?.cpu?.limits or __kubeResourceRequirements?[2]?.cpu?.limits
            "memory": __kubeResourceRequirements?[0]?.memory?.limits or __kubeResourceRequirements?[1]?.memory?.limits or __kubeResourceRequirements?[2]?.memory?.limits
            "ephemeral-storage": __kubeResourceRequirements?[0]?.disk?.limits or __kubeResourceRequirements?[1]?.disk?.limits or __kubeResourceRequirements?[2]?.disk?.limits
        }
    }

    result: {str:} = __kubeResourceRequirements

    check:
        regex.match(result?.requests?.cpu, r"^([+-]?[0-9.]+)([m]*[-+]?[0-9]*)$") if result?.requests?.cpu, "cpu must match specific regular expression"
        regex.match(result?.requests?.memory, r"^([0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if result?.requests?.memory, "memory must match specific regular expression"
        regex.match(result?.requests?["ephemeral-storage"], r"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if result?.requests?["ephemeral-storage"], "disk must match specific regular expression"
        regex.match(result?.limits?.cpu, r"^([+-]?[0-9.]+)([m]*[-+]?[0-9]*)$") if result?.limits?.cpu, "cpu must match specific regular expression"
        regex.match(result?.limits?.memory, r"^([0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if result?.limits?.memory, "memory must match specific regular expression"
        regex.match(result?.limits?["ephemeral-storage"], r"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$") if result?.limits?["ephemeral-storage"], "disk must match specific regular expression"