import base.pkg.kusion_models.kube.metadata

schema MetadataBuilder[data]:
    result?: {str:} = {
        name: metadata.__META_APP_NAME
        namespace: metadata.__META_APP_NAME
        labels: data?.labels
        annotations: data?.annotations
    }