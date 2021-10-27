schema relaxed OutputTypeMixin:
    # 控制 Render 实例化过程中生成的资源的输出类型
    # 包括 IaC、Render 本身、Render 实例化时生成的 Kubernetes 资源的输出类型
    final _VALID_OUTPUT_TYPES: [str] = ["STANDALONE", "INLINE", "IGNORE"]

    # 控制 IaC 输出类型
    _outputTypeIaC: str = "IGNORE"
    if option("iac-output-type") and option("iac-output-type") in _VALID_OUTPUT_TYPES:
        _outputTypeIaC = option("iac-output-type")
    data |= {"__settings__": {"output_type" = _outputTypeIaC}}

    # 控制 Render 本身的输出类型
    _outputTypeRender = "IGNORE"
    if option("render-output-type") and option("render-output-type") in _VALID_OUTPUT_TYPES:
        _outputTypeRender = option("render-output-type")
    __settings__ |= { "output_type" = _outputTypeRender }

    # 控制 Render 实例化时生成的 Kubernetes 资源的输出类型
    _outputTypeKube = "INLINE" if option("__konfig_output_format__")?.lower() == "raw" else "STANDALONE"
    if option("kubernetes-output-type") and option("kubernetes-output-type") in _VALID_OUTPUT_TYPES:
        _outputTypeKube = option("kubernetes-output-type")
    kubernetes |= {
        "${kindName}": [_resource | {"__settings__": {"output_type" = _outputTypeKube}} for _resource in _kubernetes[kindName]] \
            for kindName in _kubernetes
    }
