import base.pkg.kusion_models.kube.frontend.common

schema Secret(common.Metadata):
    data?: {str:str}
    stringData?: {str:str}
    type?: str
