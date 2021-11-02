import base.pkg.kusion_models.kube.metadata

schema relaxed ApplicationMixin:
    # Reference from:
    # https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
    __application_labels: {str:str} = {
        "app.kubernetes.io/name": metadata.__META_APP_NAME
        "app.kubernetes.io/env": metadata.__META_ENV_TYPE_NAME
        "app.kubernetes.io/instance": "{}-{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME).lower()
        "cluster.x-k8s.io/cluster-name": metadata.__META_CLUSTER_NAME
    }

    __application_selector: {str:str} = __application_labels

    __application_envs: [{str:}] = [
        {
            name: "APP_NAME"
            value: metadata.__META_APP_NAME
        }
        {
            name: "ENVIRONMENT"
            value: metadata.__META_ENV_TYPE_NAME
        }
        {
            name: "INSTANCE"
            value: "{}-{}".format(metadata.__META_APP_NAME, metadata.__META_ENV_TYPE_NAME).lower()
        }
        {
            name: "CLUSTER"
            value: metadata.__META_CLUSTER_NAME
        }
    ]
    