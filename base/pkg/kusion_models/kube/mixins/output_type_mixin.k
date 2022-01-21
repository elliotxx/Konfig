schema relaxed OutputTypeMixin:
    __outputTypeKube: str = "INLINE" if option("__konfig_output_format__")?.lower() == "raw" else "STANDALONE"
    kubernetes = {
        "${kindName}": [_resource | {__settings__: {output_type = __outputTypeKube}} for _resource in _kubernetes[kindName]] \
            for kindName in _kubernetes
    }
