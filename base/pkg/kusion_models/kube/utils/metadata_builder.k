import base.pkg.kusion_models.kube.metadata

MetadataBuilder = lambda data -> {str:} {
    {
        name: metadata.__META_APP_NAME
        namespace: metadata.__META_APP_NAME
        labels: data?.labels
        annotations: data?.annotations
    }
}
