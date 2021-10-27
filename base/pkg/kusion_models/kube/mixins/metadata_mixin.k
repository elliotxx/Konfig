schema relaxed MetadataMixin:
    __metadata = {
        name: data.name
        namespace: data.namespace
        labels: data.labels
        annotations: data.annotations
    }
    