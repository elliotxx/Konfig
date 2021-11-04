import base.pkg.kusion_models.kube.metadata

schema MetadataBuilder[data]:
    result?: {str:} = {
        name: data?.name
        namespace: data?.namespace or metadata.__META_APP_NAME
        labels: data?.labels
        annotations: data?.annotations
    }