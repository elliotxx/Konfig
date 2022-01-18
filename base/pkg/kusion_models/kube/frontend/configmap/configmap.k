import base.pkg.kusion_models.kube.frontend.common

schema ConfigMap(common.Metadata):
    data?: {str:str}
    binaryData?: {str:str}