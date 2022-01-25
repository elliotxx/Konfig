import kcl_plugin.utils

schema ProviderResourceBuilder:
    __settings__: {str:str} = {
        "output_type": "IGNORE"
    }

    mode: "managed" = "managed"
    """mode
    """

    $type: str
    """type
    """

    name: str
    """name
    """

    provider: Provider
    """provider
    """

    instances?: [Instance]
    """instance
    """
   
    providerMeta?: {str:}
    """providerMeta
    """
 
    # 处理逻辑
    _instances = [
        RealInstance {
            if _i.dependsOn:
                dependsOn: _i.dependsOn
            attributes: {
                if _i.name:
                    name: _i.name
                **utils.convert_case({k:v for k,v in utils.dict2array(_i.data)}, "snake")
            }
        } for _i in instances if _i
    ]

    _resource = ProviderResource {
        __settings__: {
            "output_type": "STANDALONE"
        }
        mode: mode
        type: type
        name: name
        provider: provider
        instances: _instances
        providerMeta: providerMeta
    }

    result: any = _resource

schema Instance:
    name?: str
    """instance name
    """

    data: any
    """instance data
    """

    dependsOn?: [str]
    """depends on
    """
